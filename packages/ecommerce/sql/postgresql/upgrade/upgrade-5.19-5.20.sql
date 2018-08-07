----
---- fixed ambiguity
---- Error: nsdbpg: result status: 7 message: ERROR:  column reference "tax_exempt_p" is ambiguous
----  ---         SELECT  INTO tax_exempt_p tax_exempt_p
----  +++       SELECT tax_exempt_p INTO v_tax_exempt


create OR REPLACE Function ec_tax (numeric, numeric, integer) 
returns numeric as '
DECLARE
	v_price			alias for $1;
	v_shipping		alias for $2;
	v_order_id		alias for $3;
        taxes                   ec_sales_tax_by_state%ROWTYPE;
        v_tax_exempt            ec_orders.tax_exempt_p%TYPE;
BEGIN
        SELECT tax_exempt_p INTO v_tax_exempt
        FROM ec_orders
        WHERE order_id = v_order_id;

        IF v_tax_exempt = ''t'' THEN
                return 0;
        END IF; 
        
        --SELECT t.* into taxes
        --FROM ec_orders o, ec_addresses a, ec_sales_tax_by_state t
        --WHERE o.shipping_address=a.address_id
        --AND a.usps_abbrev=t.usps_abbrev(+)
        --AND o.order_id=v_order_id;

        SELECT into taxes t.* 
	FROM ec_orders o
	    JOIN 
	ec_addresses a on (o.shipping_address=a.address_id)
	    LEFT JOIN
	ec_sales_tax_by_state t using (usps_abbrev)
	WHERE o.order_id=v_order_id;
	

        IF coalesce(taxes.shipping_p,''f'') = ''f'' THEN
                return coalesce(taxes.tax_rate,0) * v_price;
        ELSE
                return coalesce(taxes.tax_rate,0) * (v_price + v_shipping);
        END IF;
END;' language 'plpgsql';
