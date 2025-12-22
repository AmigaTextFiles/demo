<MAIN>loading |0|1</MAIN><KSCRIPT><ID>loading</ID><PLAY>loadpart |500  |0|1</PLAY></KSCRIPT>
<KRECT>red   |0|0.44|1|0.56|  |0|0|1|1| </KRECT>
<KRECT>black |0.01| 0.45 | 0.99 | 0.55|    |0.01|0.41|.99|0.59| </KRECT>
<KRECT>progbar  |0|0|0 | 0 |   |0|0|0|0| </KRECT>
<KIMG>load|data/load</KIMG><kdbm>sfx|data/chiptro</kdbm>
<KPART><ID>loadpart</ID><Fx><Pa>SetPalette</Pa><Pa>load</Pa></Fx>
<Fx><Pa>FillRC</Pa><Pa>red </Pa><Pa>CTE|1</Pa></Fx>
<Fx><Pa>FillRC</Pa><Pa>black </Pa><Pa>CTE|0</Pa></Fx>
<ktable> from0to100 | 0,0.02 | 500,0.98 </ktable>
<Fx><Pa>SetRect</Pa><Pa>progbar </Pa><Pa>CTE|0.02</Pa><Pa>CTE|0.46</Pa>
<Pa>AFT| from0to100 | 0 | 0 </Pa><Pa>CTE|0.54</Pa><Pa>4CTE|0|0|1|1</Pa></Fx>
<Fx><Pa>FillRC</Pa><Pa>progbar </Pa><Pa>CTE|2</Pa> </Fx>
<Fx><Pa>Sprite</Pa><Pa></Pa><Pa>load</Pa><Pa> cte | 0 </pa><Pa> cte | 0.39 </pa>
<Pa> cte | 0.32 </pa><Pa> cte | 0.43 </pa></Fx><fx><pa>playdbm</pa><pa>sfx</pa></fx></KPART>
