<master>

<div class="row">
  <div class="col-sm-4"></div>
  <div class="col-sm-4">



  <div class="col-sm-6">
    <formtemplate id="form"></formtemplate>
  </div>
  <div class="col-sm-6">
    <if @jm@ ne "">
      <div id="result" style="text-align:right">
      Data de Ciencia: @dc@ <br>
      Data de Lavratura: @dl@ <br>
      Data de Vencimento: @dvm@ <br><br>
    

      <b>Data Atual: @current_date@</b> <br>  
      Tributo (Principal): @p@  <br>
      <b>Juros de mora sobre o Principal: @jp@</b> <br>
      Multa proporcional: @mp@ <br>
      <b>Juros de mora sobre a Multa: @jm@</b> <br>
      Total: @total@ <br>
      </div>
    </if>
  </div>
  <div class="col-sm-4">
  </div>

</div>