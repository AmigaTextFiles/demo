<MAIN> myscript |0|1</MAIN>
<KCAM> cam_1 |0|0|0|0|0|0|1  </KCAM>
<KIMG> myimage | data/logo.iff </KIMG>
<KIMG> text1 | data/text.iff </KIMG>
<KIMG> text2 | data/text2.iff </KIMG>
<KIMG> tx | data/t.fx </KIMG>
<KIMG> txL | data/tnllast.iff </KIMG>
<KIMG> lc | data/lctnl.iff </KIMG>
<KIMG> txR | data/twrl.iff </KIMG>
<KIMG> lcR | data/rctwrl.iff </KIMG>
<KIMG> end | data/endpart1.iff </KIMG>
<KIMG> end2 | data/endpart2.iff </KIMG>
<KIMG> end3 | data/endpart3.iff </KIMG>
<KIMG> blnk | data/blank.iff </KIMG>
<KIMG> pres | data/pres.iff </KIMG>
<KIMG> lgn | data/wayneLGN.iff </KIMG> out optimize
<KIMG> lbig | data/artwaybig.iff </KIMG> out optimize
<KIMG> off | data/off.iff </KIMG>
<kdbm> dbmmusic | data/musicF  </kdbm> 2:24 = 144s = [7200]
<KSCRIPT>
    <ID> myscript </ID>
PLAY = prehravani |nazev casti | doba | offset navaznost | rychlost (minus=reverse) |
    <PLAY> blank | 25 | 0 | 1 </PLAY>0.5s 500=10s => 50=1s
fade + start mus ply
    <PLAY> part0 | 500 | 0 | 1 </PLAY>50
    <PLAY> part2 | 475 | 0 | 1 </PLAY>20    set synchro play
    <PLAY> part2 | 500 | 0 | -4 </PLAY>40   offset [1500]
main
   <PLAY> part00 | 250 | 0 | 1 </PLAY>  1750 text    palette2
    <PLAY> partx | 500 | 2250 | 1 </PLAY>50  twirl
    <PLAY> party | 500 | 2750 | 1 </PLAY>60  go scene sign!
    <PLAY> part001 | 250 | 0 | 1 </PLAY>1:10 text2
    <PLAY> part2 | 500 | 0 | 4 </PLAY> 20
    <PLAY> part1 | 500 | 0 | 1 </PLAY> 50
    <PLAY> part2 | 500 | 0 |-4 </PLAY> 60    =   2min    offset [3000]
tunel + info 2000
    <PLAY> part13 | 250 | 0 | 1 </PLAY>
    <PLAY> part133 | 250 | 3500 | 2 </PLAY> sprite
    <PLAY> part133 | 250 | 3750 | 3 </PLAY>
    <PLAY> part133 | 250 | 4000 | 4 </PLAY>
    <PLAY> part13 | 125 | 4125 | 3 </PLAY>  1000
    <PLAY> part13 | 125 | 4250 | -3 </PLAY> 
   <PLAY> part13 | 200 | 4450 | -3 </PLAY>   
    <PLAY> part13 | 200 | 4700 | 3 </PLAY>
    <PLAY> part13 | 200 | 4900 |- 3 </PLAY>      offset [2000]
[end part] 
  <PLAY> part10 | 225 | 0 | 1 </PLAY>
   <PLAY> part01 | 225 | 0 | 1 </PLAY>
    <PLAY> part02 | 225 | 0 | 1 </PLAY>2:24s
    <PLAY> SeeYa | 225 | 0 | 1 </PLAY>        offset [1000]  | 7500 2: 45
</KSCRIPT>
<KPART>
<ID> blank  </ID>
<fx><pa>stopdbm</pa></fx> 
   <Fx>
    <Pa>setpalette</Pa>
    <Pa> blnk </Pa> 
   </Fx>
  <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> blnk </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>
<KPART>
    <ID> part0  </ID>
    <fx>
        <pa> playdbm</pa>
        <pa> dbmmusic   </pa>
    </fx>
        <Fx><Pa>BindPalette</Pa>  1st is always the name of the effect.
            <Pa> bounce |0|250|250|0|1</Pa> the rate between 0->1

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> pres </Pa>     palette where to fade ( "B" )
            <Pa> pres </Pa>            optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> pres </Pa>       Palette where to fade ( "B" )
            <Pa> pres </Pa>       optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> pres </Pa>       Palette where to fade ( "B" )
            <Pa> pres </Pa>       optional source Palette(2)
        </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> pres </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>
<KPART>
    <ID> part1  </ID>
        <Fx><Pa>BindPalette</Pa>  1st is always the name of the effect.

            <Pa> bounce |0|250|250|0|1</Pa> the rate between 0->1

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> myimage </Pa>     palette where to fade ( "B" )
            <Pa> myimage </Pa>            optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> myimage </Pa>       Palette where to fade ( "B" )
            <Pa> myimage </Pa>       optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> myimage </Pa>       Palette where to fade ( "B" )
            <Pa> myimage </Pa>       optional source Palette(2)
        </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> myimage </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>
<KPART>
   <ID> part2 </ID>
   <Fx>
    <Pa>setpalette</Pa>
    <Pa> tx </Pa> 
   </Fx>
   <Fx><Pa> setcamcoord  </Pa>
       <PA> cam_1 </Pa>
       <PA> 2cte|0|0</Pa>
       <PA> aff|0|4 </Pa>
       <PA> aff|0|0.002 </Pa>  x
       <PA> aff|0|0.000 </Pa>  y 
       <PA> aff|0|0.002 </Pa>  z 
       <PA> cte|0.3 </Pa>
    </Fx>
<Fx><Pa> Tunnel </Pa>
       <Pa>  </Pa>
       <Pa> tx </Pa>
       <Pa> cam_1</Pa>   
       <Pa>CTE|1</Pa>          
       <Pa>CTE|0.6</Pa>         
       <Pa>CTE|0</Pa>         
       <Pa>CTE|0</Pa>          
       <Pa>CTE|0</Pa>         
      </Fx>
</KPART>
<KPART>
   <ID> part13 </ID>
   <Fx>
    <Pa>setpalette</Pa>
    <Pa> txl </Pa> 
   </Fx>
   <Fx><Pa> setcamcoord  </Pa>
       <PA> cam_1 </Pa>
       <PA> 2cte|0|0</Pa>
       <PA> aff|0|4 </Pa>
       <PA> aff|0|0.000 </Pa>  x
       <PA> aff|0|0.000 </Pa>  y 
       <PA> aff|0|0.000 </Pa>  z 
       <PA> cte|0.3 </Pa>
    </Fx>
<Fx><Pa> Tunnel </Pa>
       <Pa>  </Pa>
       <Pa> txl </Pa>
       <Pa> cam_1</Pa>   
       <Pa>CTE|1</Pa>          
       <Pa>CTE|0.6</Pa>         
       <Pa>CTE|0</Pa>         
       <Pa>CTE|0</Pa>          
       <Pa>CTE|0</Pa>         
      </Fx>
</KPART>
<KPART>
   <ID> part133 </ID>
   <Fx>
    <Pa>setpalette</Pa>
    <Pa> txl </Pa> 
   </Fx>
   <Fx><Pa> setcamcoord  </Pa>
       <PA> cam_1 </Pa>
       <PA> 2cte|0|0</Pa>
       <PA> aff|0|4 </Pa>
       <PA> aff|0|0.000 </Pa>  x
       <PA> aff|0|0.000 </Pa>  y 
       <PA> aff|0|0.000 </Pa>  z 
       <PA> cte|0.3 </Pa>
    </Fx>
<Fx><Pa> Tunnel </Pa>
       <Pa>  </Pa>
       <Pa> txl </Pa>
       <Pa> cam_1</Pa>   
       <Pa>CTE|1</Pa>          
       <Pa>CTE|0.6</Pa>         
       <Pa>CTE|0</Pa>         
       <Pa>CTE|0</Pa>          
       <Pa>CTE|0</Pa>         
      </Fx>
  <Fx>
    <Pa>Sprite</Pa>
    <Pa></Pa>
    <Pa> lc </Pa>
        <Pa> cte | 0  </pa> x1
        <Pa> cte | 0  </Pa> y1
        <Pa> cte | 1  </pa> x2
        <Pa> cte | 1  </Pa> y2 ???
    </Fx>
</KPART>
<KPART>
    <ID> part10  </ID>
        <Fx><Pa>BindPalette</Pa>  1st is always the name of the effect.

            <Pa> bounce |0|250|250|0|1</Pa> the rate between 0->1

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end </Pa>     palette where to fade ( "B" )
            <Pa> end </Pa>            optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end </Pa>       Palette where to fade ( "B" )
            <Pa> end </Pa>       optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end </Pa>       Palette where to fade ( "B" )
            <Pa> end </Pa>       optional source Palette(2)
        </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> end </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>
<KPART>
    <ID> part01  </ID>
        <Fx><Pa>BindPalette</Pa>  1st is always the name of the effect.

            <Pa> bounce |0|250|250|0|1</Pa> the rate between 0->1

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end2 </Pa>     palette where to fade ( "B" )
            <Pa> end2 </Pa>            optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end2 </Pa>       Palette where to fade ( "B" )
            <Pa> end2 </Pa>       optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end2 </Pa>       Palette where to fade ( "B" )
            <Pa> end2 </Pa>       optional source Palette(2)
        </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> end2 </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>
<KPART>
    <ID> part02  </ID>
        <Fx><Pa>BindPalette</Pa>  1st is always the name of the effect.

            <Pa> bounce |0|250|250|0|1</Pa> the rate between 0->1

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end3 </Pa>     palette where to fade ( "B" )
            <Pa> end3 </Pa>            optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end3 </Pa>       Palette where to fade ( "B" )
            <Pa> end3 </Pa>       optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> end3 </Pa>       Palette where to fade ( "B" )
            <Pa> end3 </Pa>       optional source Palette(2)
        </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> end3 </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>
<kpart>
    <ID> SeeYa  </ID>
        <Fx><Pa>BindPalette</Pa>  1st is always the name of the effect.

            <Pa> bounce |0|250|250|0|1</Pa> the rate between 0->1

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> off </Pa>     palette where to fade ( "B" )
            <Pa> off </Pa>            optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> off </Pa>       Palette where to fade ( "B" )
            <Pa> off </Pa>       optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa>off </Pa>       Palette where to fade ( "B" )
            <Pa> off </Pa>       optional source Palette(2)
        </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> off </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>
<kpart> 
<id> partx</id>   
  <Fx>
    <Pa>setpalette</Pa>
    <Pa> txR </Pa> 
   </Fx>
 <Fx>
        <Pa> Twirl </Pa>
        <Pa></Pa>
        <Pa> txR </Pa>
        <Pa>SIN|0|0.25|0.25</Pa> 
        <Pa>COS|0|0.25|0.25</Pa> 
        <Pa>SIN|0|0.05|1</Pa>
        <Pa>CTE|0</Pa>  
        <Pa>CTE|0</Pa>  
        <Pa>CTE|0</Pa>        
        <Pa>SIN|0|0.3|0.5</Pa>
        <Pa>COS|0|0.1|32</Pa> 
        <Pa>CTE|0</Pa>
    </Fx>
</kpart>
<kpart> 
<id> party</id>   
  <Fx>
    <Pa>setpalette</Pa>
    <Pa> txR </Pa> 
   </Fx>
 <Fx>
        <Pa> Twirl </Pa>
        <Pa></Pa>
        <Pa> txR </Pa>
        <Pa>SIN|0|0.25|0.25</Pa> 
        <Pa>COS|0|0.25|0.25</Pa> 
        <Pa>SIN|0|0.05|1</Pa>
        <Pa>CTE|0</Pa>  
        <Pa>CTE|0</Pa>  
        <Pa>CTE|0</Pa>        
        <Pa>SIN|0|0.3|0.5</Pa>
        <Pa>COS|0|0.1|32</Pa> 
        <Pa>CTE|0</Pa>
    </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> lcr </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</kpart>
<kpart>
    <ID> part00  </ID>
        <Fx><Pa>BindPalette</Pa>  1st is always the name of the effect.

            <Pa> bounce |0|250|250|0|1</Pa> the rate between 0->1

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> text1 </Pa>     palette where to fade ( "B" )
            <Pa> text1 </Pa>            optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> text1 </Pa>       Palette where to fade ( "B" )
            <Pa> text1 </Pa>       optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> text1 </Pa>       Palette where to fade ( "B" )
            <Pa> text1 </Pa>       optional source Palette(2)
        </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> text1 </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>
<kpart>
    <ID> part001  </ID>
        <Fx><Pa>BindPalette</Pa>  1st is always the name of the effect.
            <Pa> bounce |0|250|250|0|1</Pa> the rate between 0->1

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> text2 </Pa>     palette where to fade ( "B" )
            <Pa> text2 </Pa>            optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> text2 </Pa>       Palette where to fade ( "B" )
            <Pa> text2 </Pa>       optional source Palette(2)

            <Pa>CTE|0</Pa>              type of fade:0,1,2,3
            <Pa>CTE|0</Pa>            optional color 0->255 (0)
            <Pa> text2 </Pa>       Palette where to fade ( "B" )
            <Pa> text2 </Pa>       optional source Palette(2)
        </Fx>
    <Fx>
        <Pa>Sprite</Pa>
        <Pa></Pa>
        <Pa> text2 </Pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 0 </pa>
        <Pa> cte | 1 </pa>
        <Pa> cte | 1 </pa>
    </Fx>
</KPART>