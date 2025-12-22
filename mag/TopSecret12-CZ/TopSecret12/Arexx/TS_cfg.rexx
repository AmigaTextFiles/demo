/*           Tento naprosto geni¡ln… program v Arexxu vytvo“il            */
/*  dne 06.Srpna 1998, 16:39:47 velkej koder L¡hve of Horizontal Lamerz   */
/*                                                                        */
/* Va⁄te  si  toho, proto⁄e sem d≈lal poprvŸ f Arexxu a f”echno sem musel */
/*      vy√…st z chytrejch kn…⁄ek. Ale funguje to a to je hlavn………!       */
/*                          A‘ ⁄ije TOP SECRET!                           */
/*                                                                        */
/*        Toto makro nen… ur√eno k rozmno⁄ov¡n…, byl vytvo“en pro         */
/*                       p“irozenou pot“ebu autora!                       */
/*                                                                        */
/*         PROGRAM PRO DETEKCI NASTAVENÈ A PRO SPOUÛTÂNÈ PÚEHR·VA„E       */

addlib('rexxreqtools.library',0,-30)
If exists('S:TopSecret.config') then do
 if open(soubor, 'S:TopSecret.config', 'R') then do
   str=readln(soubor)
   prikaz=insert(str,' HIDE')
   call close(soubor)
   address command (prikaz)
   exit
 end
end

call RTEZREQUEST('Nem¡” nastavenou cestu k HippoPlayeru!', '_Nastavit', 'Upozorn≈n…!')

cfg=RTFILEREQUEST(,,'Najdi spou”t≈c… soubor HippoPlayeru')
If Open(soubor, 'S:TopSecret.config', 'W') then do
    call writeln(soubor, cfg)
    call close(soubor)
end
if open(soubor, 'S:TopSecret.config', 'R') then do
   str=readln(soubor)
   prikaz=insert(str,' HIDE')
   call close(soubor)
end
call RTEZREQUEST('Konfigurace zaps¡na do S:TopSecret.config', '_Ou kej! Spus‘ to!!', 'Zpr¡va!')

address command (prikaz)
exit
