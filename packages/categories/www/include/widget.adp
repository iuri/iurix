<if @trees:rowcount@ gt 0>
  <multiple name=trees>
    @trees.tree_name@:
    <select name="@name@"<if @trees.assign_single_p;literal@ false> #categories.multiple#</if>>
    <if @trees.assign_single_p;literal@ true and @trees.require_category_p;literal@ false><option value=""></if>
    <group column=tree_id>
      <option value="@trees.category_id@"<if @trees.selected_p;literal@ true> #categories.selected#</if>>@trees.indent;noquote@@trees.category_name@
    </group>
    </select>
  </multiple>
</if>

