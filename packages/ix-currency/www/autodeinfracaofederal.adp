<master>
  <property name="doc(title)">SELIC</property>
  <property name="context">SELIC</property>

<include src="/packages/ix-currency/lib/currencies-display">

<div class="row" style="padding:15px;">
  <div class="col-sm-4">
    <div class="row">
      <div class="col"><h2>SELIC</h2></div>
    </div>
    <div class="row" style="border:solid #000 1px">
      <div class="col-sm-3"><h2>M&Ecirc;S</h2></div>
      <div class="col-sm-3"><h2>% MENSAL</h2></div>
      <div class="col-sm-3"><h2>ACUMULADO</h2></div>
      <div class="col-sm-3"><h2>TAXA A UTILIZAR</h2></div>
    </div>
    <multiple name="rates">
    <div class="row" style="border:solid #000 1px">
      <div class="col-sm-3">@rates.abrev_date@</div>
      <div class="col-sm-3" style="background:#99E599;">@rates.rate@</div>
      <div class="col-sm-3">@rates.acm_rate@</div>
      <div class="col-sm-3" style="background:#E599CF">@rates.applied_rate@</div>
    </div>

    </multiple>

  </div>
  <div class="col-sm-8">


    <formtemplate id="form"></formtemplate>

  </div>
</div>
<div class="row">
  <div class="col-sm-2"></div>
  <div class="col-sm-8">
    <p>
    <h4>Objetivo:</h4> Atualizar automaticamente com juros Selic simples o valor dos débitos tributários federais exigidos por meio de Lançamento de Ofício (Autos de Infração).<br>
    <h4>Justificativa:</h4> (1) Normalmente a cobrança é feita para vários débitos, cada um com vencimento diferente. Assim, a cobrança haveria de ser atualizada manualmente para cada débito, o que tende a tornar o cálculo de atualização complexo, especialmente quando há vários tributos vencidos cobrados em conjunto. (2) Além disso, a multa cobrada tem vencimento diferente dos tributos aos quais ela se refere. Então, é necessário apurar juros sobre a multa, separados dos juros sobre o principal.<br>
    <h4>Funcionamento:</h4> (1) Juros sobre o principal: Pressupõe-se que os juros apurados desde o vencimento até o Lançamento de Ofício estão calculados corretamente pela RFB. Então, o sistema calcula os juros complementares, do Lançamento de Ofício até uma data posterior. (2) Juros sobre a multa: Os juros sobre a multa são devidos após o vencimento do Lançamento de Ofício, em 30 dias após a ciência da cobrança.<br>
    <h4>Isenção de responsabilidade:</h4> O uso desse programa deve ser tomado como auxílio do usuário, mas é de inteira responsabilidade deste averiguar a correção da informação. Ao usar o sistema, você concorda em não buscar responsabilizar os idealizadores do sistema.
    </p>
  </div>
  <div class="col-sm-2"></div>
</div>



<script>
$("#p").mask("$.$$0,00", {reverse :true});
$("#jp").mask("$.$$0,00", {reverse :true});
$("#jm").mask("$.$$0,00", {reverse :true});
$("#mp").mask("$.$$0,00", {reverse :true});
$("#subtotal").mask("$.$$0,00", {reverse :true});

</script>