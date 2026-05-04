// BluesKit.ck
public class BluesKit {
    
    69 => static int KEY;       //C(60), A(69)
    80 => static int BPM;       //Beats Per Minute
    [0, 3, 5, 6, -5, -2] @=> static int blues[];        //藍調音階 1, b3, 4, b5, 5, b7
    [0, 2, 4, 5, 7, 9, 11] @=> static int major[];      //大調音階 1, 2, 3, 4, 5, 6, 7
    ["V7",  "IV7", "I7", "V7",
/*
     "I7",  "I7",  "I7", "I7", 
     "IV7", "IV7", "I7", "I7",
     "V7",  "IV7", "I7", "V7",
    
     "I7",  "I7",  "I7", "I7",
     "IV7", "IV7", "I7", "I7",
     "V7",  "IV7", "I7", "V7",
    
     "I7",  "I7",  "I7", "I7",
     "IV7", "IV7", "I7", "I7",
     "V7",  "IV7", "I7", "V7",
*/
     "I7",  "I7",  "I7", "I7",
     "IV7", "IV7", "I7", "I7",
     "V7",  "IV7", "I7", "I7"] @=> static string progression[];    //完整和弦進行

    //[1, 1, 1, 1,  4, 4, 1, 1,  5, 4, 1, 1] @=> static int progression[];    //12 Bar Blues和弦進行
    //[1, 4, 1, 1,  4, 4, 1, 1,  5, 4, 1, 5] @=> int progression[];             //from the top
    //[5, 4, 1, 5, 1, 4, 1, 1,  4, 4, 1, 1,  5, 4, 1, 5] @=> int progression[]; //from the V
    //[1, 4, 1, 1,  4, 4, 1, 6,  2, 5, 1, 5] @=> int progression[];             //wiwi

}
