0x2AAB4084C   strb     w3, [x22, #0x30]     
0x2AAB40850   stp      x1, x2, [x22, #0x18] 
0x2AAB40854   str      x0, [x22, #0x10]     
0x2AAB40858   adrp     x16, 0               ; 0x2aab40000
0x2AAB4085C   add      x16, x16, #0x874     
0x2AAB40860   paciza   x16                  
0x2AAB40864   mov      x0, x16              
0x2AAB40868   mov      x1, #0x0             
0x2AAB4086C   mov      x2, #0x0             
0x2AAB40870   b        0x2b00b2ae0          
0x2AAB5015C   pacibsp                       
0x2AAB50160   str      x28, [sp, #-0x60]!   
0x2AAB50164   stp      x27, x26, [sp, #0x10] 
0x2AAB50168   stp      x25, x24, [sp, #0x20] 
0x2AAB5016C   stp      x23, x22, [sp, #0x30] 
0x2AAB50170   stp      x20, x19, [sp, #0x40] 
0x2AAB50174   stp      x29, x30, [sp, #0x50] 
0x2AAB50178   add      x29, sp, #0x50       
0x2AAB5017C   sub      sp, sp, #0xe0        
0x2AAB50180   stp      x0, x21, [x29, #-0xb0] 
0x2AAB50184   stur     x5, [x29, #-0x88]    
0x2AAB50188   stur     w4, [x29, #-0x90]    
0x2AAB5018C   mov      x19, x3              
0x2AAB50190   mov      x26, x2              
0x2AAB50194   mov      x22, x1              
0x2AAB50198   adrp     x0, 144469           ; 0x2cdfa5000
0x2AAB5019C   add      x0, x0, #0x7f0       
0x2AAB501A0   adrp     x1, 1317             ; 0x2ab075000
0x2AAB501A4   add      x1, x1, #0x420       
0x2AAB501A8   bl       0x2aab22034          
0x2AAB501AC   ldr      x16, [x0, #-0x8]!    
0x2AAB501B0   mov      x17, x0              
0x2AAB501B4   movk     x17, #0x2e3f, lsl #48 
0x2AAB501B8   autda    x16, x17             
0x2AAB501BC   ldr      x9, [x16, #0x40]     
0x2AAB501C0   add      x8, x9, #0xf         
0x2AAB501C4   and      x8, x8, #0xfffffffffffffff0 
0x2AAB501C8   adrp     x17, 153973          ; 0x2d04c5000
0x2AAB501CC   add      x17, x17, #0xf48     
0x2AAB501D0   ldr      x16, [x17]           
0x2AAB501D4   blraa    x16, x17             
0x2AAB501D8   mov      x9, sp               
0x2AAB501DC   sub      x8, x9, x8           
0x2AAB501E0   stur     x8, [x29, #-0xd8]    
0x2AAB501E4   mov      sp, x8               
0x2AAB501E8   mov      x0, #0x0             
0x2AAB501EC   bl       0x2aab7e26c          
0x2AAB501F0   stur     x0, [x29, #-0xf0]    
0x2AAB501F4   mov      x8, x0               
0x2AAB501F8   ldr      x16, [x8, #-0x8]!    
0x2AAB501FC   mov      x17, x8              
0x2AAB50200   movk     x17, #0x2e3f, lsl #48 
0x2AAB50204   autda    x16, x17             
0x2AAB50208   ldr      x8, [x16, #0x40]     
0x2AAB5020C   mov      x9, x8               
0x2AAB50210   adrp     x17, 153973          ; 0x2d04c5000
0x2AAB50214   add      x17, x17, #0xf48     
0x2AAB50218   ldr      x16, [x17]           
0x2AAB5021C   blraa    x16, x17             
0x2AAB50220   mov      x9, sp               
0x2AAB50224   add      x10, x8, #0xf        
0x2AAB50228   and      x12, x10, #0xfffffffffffffff0 
0x2AAB5022C   sub      x9, x9, x12          
0x2AAB50230   stur     x9, [x29, #-0xc0]    
0x2AAB50234   mov      sp, x9               
0x2AAB50238   mov      x9, x8               
0x2AAB5023C   adrp     x17, 153973          ; 0x2d04c5000
0x2AAB50240   add      x17, x17, #0xf48     
0x2AAB50244   ldr      x16, [x17]           
0x2AAB50248   blraa    x16, x17             
0x2AAB5024C   mov      x8, sp               
0x2AAB50250   sub      x8, x8, x12          
0x2AAB50254   stur     x8, [x29, #-0xe8]    
0x2AAB50258   mov      sp, x8               
0x2AAB5025C   mov      x0, #0x0             
0x2AAB50260   bl       _$s13CoreAIRuntime27InferenceFunctionDescriptorVMa 
0x2AAB50264   mov      x23, x0              
0x2AAB50268   mov      x8, x0               
0x2AAB5026C   ldr      x16, [x8, #-0x8]!    
0x2AAB50270   mov      x17, x8              
0x2AAB50274   movk     x17, #0x2e3f, lsl #48 
0x2AAB50278   autda    x16, x17             
0x2AAB5027C   ldr      x8, [x16, #0x40]     
0x2AAB50280   mov      x9, x8               
0x2AAB50284   adrp     x17, 153973          ; 0x2d04c5000
0x2AAB50288   add      x17, x17, #0xf48     
0x2AAB5028C   ldr      x16, [x17]           
0x2AAB50290   blraa    x16, x17             
0x2AAB50294   mov      x9, sp               
0x2AAB50298   add      x8, x8, #0xf         
0x2AAB5029C   and      x8, x8, #0xfffffffffffffff0 
0x2AAB502A0   sub      x8, x9, x8           
0x2AAB502A4   stur     x8, [x29, #-0x98]    
0x2AAB502A8   mov      sp, x8               
0x2AAB502AC   ldr      x8, [x22]            
0x2AAB502B0   stur     x8, [x29, #-0xd0]    
0x2AAB502B4   ldr      x8, [x19]            
0x2AAB502B8   stur     x8, [x29, #-0x48]    
0x2AAB502BC   mov      x0, #0x0             
0x2AAB502C0   bl       _$s13CoreAIRuntime22InferenceFunctionStateVMa 
0x2AAB502C4   stur     x0, [x29, #-0xe0]    
0x2AAB502C8   ldrsw    x8, [x0, #0x1c]      
0x2AAB502CC   stur     x23, [x29, #-0xf8]   
0x2AAB502D0   ldrsw    x9, [x23, #0x1c]     
0x2AAB502D4   stur     x20, [x29, #-0xa0]   
0x2AAB502D8   add      x28, x20, x8         
0x2AAB502DC   add      x8, x28, x9          
0x2AAB502E0   ldr      x8, [x8]             
0x2AAB502E4   ldr      x22, [x8, #0x10]     
0x2AAB502E8   cbz      x22, 0x2aab50328     
0x2AAB502EC   mov      x25, #0x0            
0x2AAB502F0   add      x27, x8, #0x20       
0x2AAB502F4   ldr      x19, [x26]           
0x2AAB502F8   add      x8, x27, x25, lsl #4 
0x2AAB502FC   ldp      x23, x24, [x8]       
0x2AAB50300   ldr      x8, [x19, #0x10]     
0x2AAB50304   cbz      x8, 0x2aab503c4      
0x2AAB50308   mov      x0, x23              
0x2AAB5030C   mov      x1, x24              
0x2AAB50310   mov      x20, x19             
0x2AAB50314   bl       0x2aab73b00          
0x2AAB50318   tbz      w1, #0x0, 0x2aab503c4 
0x2AAB5031C   add      x25, x25, #0x1       
0x2AAB50320   subs     x22, x22, #0x1       
0x2AAB50324   b.ne     0x2aab502f8          
0x2AAB50328   ldr      x19, [x26]           
0x2AAB5032C   mov      x0, x19              
0x2AAB50330   bl       0x2b00abc60          
0x2AAB50334   sub      x20, x29, #0x48      
0x2AAB50338   bl       0x2aab50b40          
0x2AAB5033C   cbz      x1, 0x2aab5048c      
0x2AAB50340   mov      x24, x0              
0x2AAB50344   mov      x23, x1              
0x2AAB50348   mov      x8, #-0x2000000000000000 
0x2AAB5034C   stp      xzr, x8, [x29, #-0x78] 
0x2AAB50350   sub      x20, x29, #0x78      
0x2AAB50354   mov      w0, #0x25            
0x2AAB50358   bl       0x2b00afd50          
0x2AAB5035C   ldur     x0, [x29, #-0x70]    
0x2AAB50360   bl       0x2b00aac30          
0x2AAB50364   adrp     x8, 1342             ; 0x2ab08e000
0x2AAB50368   add      x8, x8, #0x540       
0x2AAB5036C   sub      x8, x8, #0x20        
0x2AAB50370   orr      x8, x8, #0x8000000000000000 
0x2AAB50374   mov      x9, #0x17            
0x2AAB50378   movk     x9, #0xd000, lsl #48 
0x2AAB5037C   add      x9, x9, #0xc         
0x2AAB50380   stp      x9, x8, [x29, #-0x78] 
0x2AAB50384   mov      x0, x24              
0x2AAB50388   mov      x1, x23              
0x2AAB5038C   bl       0x2b00aafe0          
0x2AAB50390   mov      x0, x23              
0x2AAB50394   bl       0x2b00aac30          
0x2AAB50398   ldp      x20, x22, [x29, #-0x78] 
0x2AAB5039C   bl       0x2aab1bd30          
0x2AAB503A0   mov      x1, x0               
0x2AAB503A4   adrp     x0, 162681           ; 0x2d26c9000
0x2AAB503A8   add      x0, x0, #0xfd8       
0x2AAB503AC   mov      x2, #0x0             
0x2AAB503B0   mov      w3, #0x0             
0x2AAB503B4   bl       0x2b00abc30          
0x2AAB503B8   mov      x24, x0              
0x2AAB503BC   strb     wzr, [x1]            
0x2AAB503C0   b        0x2aab50440          
0x2AAB503C4   mov      x8, #-0x2000000000000000 
0x2AAB503C8   stp      xzr, x8, [x29, #-0x78] 
0x2AAB503CC   sub      x20, x29, #0x78      
0x2AAB503D0   mov      w0, #0x1a            
0x2AAB503D4   bl       0x2b00afd50          
0x2AAB503D8   ldur     x0, [x29, #-0x70]    
0x2AAB503DC   bl       0x2b00aac30          
0x2AAB503E0   adrp     x8, 1342             ; 0x2ab08e000
0x2AAB503E4   add      x8, x8, #0x520       
0x2AAB503E8   sub      x8, x8, #0x20        
0x2AAB503EC   orr      x8, x8, #0x8000000000000000 
0x2AAB503F0   mov      x9, #0x17            
0x2AAB503F4   movk     x9, #0xd000, lsl #48 
0x2AAB503F8   stp      x9, x8, [x29, #-0x78] 
0x2AAB503FC   mov      x0, x23              
0x2AAB50400   mov      x1, x24              
0x2AAB50404   bl       0x2b00aafe0          
0x2AAB50408   mov      w0, #0x2e            
0x2AAB5040C   mov      x1, #-0x1f00000000000000 
0x2AAB50410   bl       0x2b00aafe0          
0x2AAB50414   ldp      x20, x22, [x29, #-0x78] 
0x2AAB50418   bl       0x2aab1bd30          
0x2AAB5041C   mov      x1, x0               
0x2AAB50420   adrp     x0, 162681           ; 0x2d26c9000
0x2AAB50424   add      x0, x0, #0xfd8       
0x2AAB50428   mov      x2, #0x0             
0x2AAB5042C   mov      w3, #0x0             
0x2AAB50430   bl       0x2b00abc30          
0x2AAB50434   mov      x24, x0              
0x2AAB50438   mov      w8, #0x1             
0x2AAB5043C   strb     w8, [x1]             
0x2AAB50440   stp      x20, x22, [x1, #0x8] 
0x2AAB50444   mov      x21, x0              
0x2AAB50448   bl       0x2b00abd90          
0x2AAB5044C   ldur     x20, [x29, #-0x48]   
0x2AAB50450   mov      x0, x19              
0x2AAB50454   bl       0x2b00aac30          
0x2AAB50458   mov      x0, x20              
0x2AAB5045C   bl       0x2b00aac30          
0x2AAB50460   mov      x0, x27              
0x2AAB50464   mov      x1, x22              
0x2AAB50468   mov      x21, x24             
0x2AAB5046C   sub      sp, x29, #0x50       
0x2AAB50470   ldp      x29, x30, [sp, #0x50] 
0x2AAB50474   ldp      x20, x19, [sp, #0x40] 
0x2AAB50478   ldp      x23, x22, [sp, #0x30] 
0x2AAB5047C   ldp      x25, x24, [sp, #0x20] 
0x2AAB50480   ldp      x27, x26, [sp, #0x10] 
0x2AAB50484   ldr      x28, [sp], #0x60     
0x2AAB50488   retab                         
0x2AAB5048C   mov      x0, x28              
0x2AAB50490   ldur     x26, [x29, #-0x98]   
0x2AAB50494   mov      x1, x26              
0x2AAB50498   bl       0x2aab5179c          
0x2AAB5049C   ldur     x8, [x29, #-0xd0]    
0x2AAB504A0   stur     x8, [x29, #-0x78]    
0x2AAB504A4   mov      w23, #0x101          
0x2AAB504A8   movk     w23, #0x1, lsl #16   
0x2AAB504AC   ldur     x21, [x29, #-0xb0]   
0x2AAB504B0   mov      x0, x21              
0x2AAB504B4   bl       0x2b00abd50          
0x2AAB504B8   ldur     x28, [x29, #-0x88]   
0x2AAB504BC   mov      x0, x28              
0x2AAB504C0   bl       0x2b00abd50          
0x2AAB504C4   sub      x0, x29, #0x78       
0x2AAB504C8   sub      x1, x29, #0x48       
0x2AAB504CC   ldur     w8, [x29, #-0x90]    
0x2AAB504D0   and      w4, w8, w23          
0x2AAB504D4   sub      x6, x29, #0x60       
0x2AAB504D8   ldur     x20, [x29, #-0xc0]   
0x2AAB504DC   mov      x8, x20              
0x2AAB504E0   ldur     x27, [x29, #-0xa0]   
0x2AAB504E4   mov      x2, x27              
0x2AAB504E8   mov      x3, x21              
0x2AAB504EC   mov      x5, x28              
0x2AAB504F0   ldur     x21, [x29, #-0xa8]   
0x2AAB504F4   bl       0x2aab75c70          
0x2AAB504F8   cbz      x21, 0x2aab505fc     
0x2AAB504FC   ldur     x20, [x29, #-0x60]   
0x2AAB50500   adrp     x8, 150687           ; 0x2cf7ef000
0x2AAB50504   add      x8, x8, #0x698       
0x2AAB50508   ldr      x8, [x8]             
0x2AAB5050C   add      x22, x20, x8         
0x2AAB50510   sub      x1, x29, #0x78       
0x2AAB50514   mov      x0, x22              
0x2AAB50518   mov      w2, #0x1             
0x2AAB5051C   mov      x3, #0x0             
0x2AAB50520   bl       0x2b00abc50          
0x2AAB50524   mov      x0, x22              
0x2AAB50528   ldur     x24, [x29, #-0xd8]   
0x2AAB5052C   mov      x1, x24              
0x2AAB50530   bl       0x2aab517f8          
0x2AAB50534   ldur     x25, [x29, #-0xe0]   
0x2AAB50538   mov      x17, x25             
0x2AAB5053C   ldr      x16, [x17, #-0x8]!   
0x2AAB50540   movk     x17, #0x2e3f, lsl #48 
0x2AAB50544   autda    x16, x17             
0x2AAB50548   mov      x17, x16             
0x2AAB5054C   xpacd    x17                  
0x2AAB50550   cmp      x16, x17             
0x2AAB50554   b.eq     0x2aab5055c          
0x2AAB50558   brk      #0xc472              
0x2AAB5055C   mov      x23, x16             
0x2AAB50560   mov      x8, x16              
0x2AAB50564   ldr      x9, [x8, #0x38]!     
0x2AAB50568   mov      x0, x22              
0x2AAB5056C   mov      w1, #0x1             
0x2AAB50570   mov      w2, #0x1             
0x2AAB50574   mov      x3, x25              
0x2AAB50578   mov      x17, x8              
0x2AAB5057C   movk     x17, #0xa0d1, lsl #48 
0x2AAB50580   blraa    x9, x17              
0x2AAB50584   ldr      x8, [x23, #0x30]!    
0x2AAB50588   mov      x0, x24              
0x2AAB5058C   mov      w1, #0x1             
0x2AAB50590   mov      x2, x25              
0x2AAB50594   mov      x17, x23             
0x2AAB50598   movk     x17, #0x60f0, lsl #48 
0x2AAB5059C   blraa    x8, x17              
0x2AAB505A0   cmp      w0, #0x1             
0x2AAB505A4   b.eq     0x2aab50b2c          
0x2AAB505A8   adrp     x16, 17              ; 0x2aab61000
0x2AAB505AC   add      x16, x16, #0xed4     ; _$s13CoreAIRuntime22InferenceFunctionStateVMa
0x2AAB505B0   mov      x17, #0x376f         
0x2AAB505B4   pacia    x16, x17             
0x2AAB505B8   mov      x2, x16              
0x2AAB505BC   mov      x0, x24              
0x2AAB505C0   mov      x1, x27              
0x2AAB505C4   bl       0x2aab5190c          
0x2AAB505C8   adrp     x8, 150687           ; 0x2cf7ef000
0x2AAB505CC   add      x8, x8, #0x6a0       
0x2AAB505D0   ldr      x8, [x8]             
0x2AAB505D4   ldr      x24, [x20, x8]       
0x2AAB505D8   mov      x21, x24             
0x2AAB505DC   bl       0x2b00abd90          
0x2AAB505E0   mov      x0, x24              
0x2AAB505E4   bl       0x2b00b2f60          
0x2AAB505E8   mov      x0, x20              
0x2AAB505EC   bl       0x2b00aad00          
0x2AAB505F0   mov      x0, x26              
0x2AAB505F4   bl       0x2aab51860          
0x2AAB505F8   b        0x2aab5044c          
0x2AAB505FC   adrp     x16, 46              ; 0x2aab7e000
0x2AAB50600   add      x16, x16, #0x26c     
0x2AAB50604   mov      x17, #0x376f         
0x2AAB50608   pacia    x16, x17             
0x2AAB5060C   mov      x2, x16              
0x2AAB50610   mov      x0, x20              
0x2AAB50614   ldur     x25, [x29, #-0xe8]   
0x2AAB50618   mov      x1, x25              
0x2AAB5061C   mov      x22, x21             
0x2AAB50620   bl       0x2aab5190c          
0x2AAB50624   mov      x20, x25             
0x2AAB50628   mov      x21, x22             
0x2AAB5062C   bl       0x2aab78d0c          
0x2AAB50630   mov      x24, x21             
0x2AAB50634   cbnz     x21, 0x2aab5064c     
0x2AAB50638   mov      x20, x25             
0x2AAB5063C   mov      x21, x24             
0x2AAB50640   bl       0x2aab791ec          
0x2AAB50644   mov      x24, x21             
0x2AAB50648   cbz      x21, 0x2aab506b0     
0x2AAB5064C   ldur     x8, [x29, #-0xf0]    
0x2AAB50650   ldrsw    x8, [x8, #0x2c]      
0x2AAB50654   adrp     x16, 17              ; 0x2aab61000
0x2AAB50658   add      x16, x16, #0xed4     ; _$s13CoreAIRuntime22InferenceFunctionStateVMa
0x2AAB5065C   mov      x17, #0x376f         
0x2AAB50660   pacia    x16, x17             
0x2AAB50664   mov      x2, x16              
0x2AAB50668   add      x0, x25, x8          
0x2AAB5066C   mov      x1, x27              
0x2AAB50670   bl       0x2aab5190c          
0x2AAB50674   mov      x21, x24             
0x2AAB50678   bl       0x2b00abd90          
0x2AAB5067C   mov      x0, x26              
0x2AAB50680   bl       0x2aab51860          
0x2AAB50684   ldr      x0, [x25]            
0x2AAB50688   bl       0x2b00aac30          
0x2AAB5068C   ldr      x0, [x25, #0x8]      
0x2AAB50690   bl       0x2b00aac30          
0x2AAB50694   ldr      x0, [x25, #0x10]     
0x2AAB50698   bl       0x2b00aad00          
0x2AAB5069C   ldr      x0, [x25, #0x18]     
0x2AAB506A0   bl       0x2b00aac30          
0x2AAB506A4   ldr      x0, [x25, #0x30]     
0x2AAB506A8   bl       0x2b00aad00          
0x2AAB506AC   b        0x2aab5044c          
0x2AAB506B0   mov      x20, x27             
0x2AAB506B4   ldp      x27, x28, [x25]      
0x2AAB506B8   ldr      x22, [x25, #0x10]    
0x2AAB506BC   ldur     x8, [x29, #-0xf0]    
0x2AAB506C0   ldrsw    x8, [x8, #0x2c]      
0x2AAB506C4   adrp     x16, 17              ; 0x2aab61000
0x2AAB506C8   add      x16, x16, #0xed4     ; _$s13CoreAIRuntime22InferenceFunctionStateVMa
0x2AAB506CC   mov      x17, #0x376f         
0x2AAB506D0   pacia    x16, x17             
0x2AAB506D4   mov      x2, x16              
0x2AAB506D8   add      x0, x25, x8          
0x2AAB506DC   mov      x1, x20              
0x2AAB506E0   bl       0x2aab5190c          
0x2AAB506E4   mov      x0, x22              
0x2AAB506E8   bl       0x2b00abd50          
0x2AAB506EC   ldur     w8, [x29, #-0x90]    
0x2AAB506F0   and      w3, w8, w23          
0x2AAB506F4   mov      x0, x27              
0x2AAB506F8   mov      x1, x28              
0x2AAB506FC   mov      x2, x22              
0x2AAB50700   ldur     x4, [x29, #-0x88]    
0x2AAB50704   mov      x21, x24             
0x2AAB50708   bl       0x2aab50eac          
0x2AAB5070C   mov      x24, x21             
0x2AAB50710   cbz      x21, 0x2aab5073c     
0x2AAB50714   mov      x0, x26              
0x2AAB50718   bl       0x2aab51860          
0x2AAB5071C   mov      x0, x28              
0x2AAB50720   bl       0x2b00aac30          
0x2AAB50724   mov      x0, x27              
0x2AAB50728   bl       0x2b00aac30          
0x2AAB5072C   mov      x0, x22              
0x2AAB50730   mov      w1, #0x2             
0x2AAB50734   bl       0x2b00b2a90          
0x2AAB50738   b        0x2aab5069c          
0x2AAB5073C   stur     x0, [x29, #-0xa8]    
0x2AAB50740   sub      x8, x29, #0x28       
0x2AAB50744   stur     x27, [x8, #-0x100]   
0x2AAB50748   sub      x8, x29, #0x20       
0x2AAB5074C   stur     x22, [x8, #-0x100]   
0x2AAB50750   adrp     x8, 120395           ; 0x2c819b000
0x2AAB50754   ldr      x8, [x8, #0xfe8]     
0x2AAB50758   stur     x8, [x29, #-0x78]    
0x2AAB5075C   ldur     x8, [x29, #-0xf8]    
0x2AAB50760   ldrsw    x8, [x8, #0x24]      
0x2AAB50764   add      x8, x26, x8          
0x2AAB50768   ldr      x23, [x8]            
0x2AAB5076C   ldur     x25, [x29, #-0x48]   
0x2AAB50770   ldr      x8, [x23, #0x10]     
0x2AAB50774   ldr      x9, [x25, #0x10]     
0x2AAB50778   sub      x22, x8, x9          
0x2AAB5077C   adrp     x0, 144469           ; 0x2cdfa5000
0x2AAB50780   add      x0, x0, #0x7f8       
0x2AAB50784   adrp     x1, 1317             ; 0x2ab075000
0x2AAB50788   add      x1, x1, #0x3b8       
0x2AAB5078C   bl       0x2aab22034          
0x2AAB50790   mov      x1, x0               
0x2AAB50794   sub      x20, x29, #0x78      
0x2AAB50798   mov      x0, x22              
0x2AAB5079C   bl       0x2b00b4ae0          
0x2AAB507A0   ldr      x8, [x23, #0x10]     
0x2AAB507A4   stur     x8, [x29, #-0x88]    
0x2AAB507A8   cbz      x8, 0x2aab50abc      
0x2AAB507AC   mov      x22, #0x0            
0x2AAB507B0   add      x8, x23, #0x20       
0x2AAB507B4   stur     x8, [x29, #-0x90]    
0x2AAB507B8   ldur     x27, [x29, #-0x78]   
0x2AAB507BC   ldur     x23, [x29, #-0xa8]   
0x2AAB507C0   add      x8, x23, #0x20       
0x2AAB507C4   stur     x8, [x29, #-0xb0]    
0x2AAB507C8   sub      x8, x29, #0x30       
0x2AAB507CC   stur     x28, [x8, #-0x100]   
0x2AAB507D0   stur     x25, [x29, #-0xd8]   
0x2AAB507D4   b        0x2aab507f4          
0x2AAB507D8   mov      x0, x26              
0x2AAB507DC   bl       0x2b00aac30          
0x2AAB507E0   ldur     x23, [x29, #-0xa8]   
0x2AAB507E4   add      x22, x22, #0x1       
0x2AAB507E8   ldur     x8, [x29, #-0x88]    
0x2AAB507EC   cmp      x8, x22              
0x2AAB507F0   b.eq     0x2aab50aa8          
0x2AAB507F4   ldur     x9, [x29, #-0x90]    
0x2AAB507F8   add      x8, x9, x22, lsl #4  
0x2AAB507FC   ldp      x20, x26, [x8]       
0x2AAB50800   ldr      x21, [x25, #0x10]    
0x2AAB50804   mov      x0, x26              
0x2AAB50808   bl       0x2b00abc60          
0x2AAB5080C   cbz      x21, 0x2aab50840     
0x2AAB50810   mov      x0, x20              
0x2AAB50814   mov      x1, x26              
0x2AAB50818   mov      x28, x26             
0x2AAB5081C   mov      x26, x20             
0x2AAB50820   mov      x20, x25             
0x2AAB50824   bl       0x2aab73b00          
0x2AAB50828   mov      x20, x26             
0x2AAB5082C   mov      x26, x28             
0x2AAB50830   tbz      w1, #0x0, 0x2aab50840 
0x2AAB50834   mov      x0, x26              
0x2AAB50838   bl       0x2b00aac30          
0x2AAB5083C   b        0x2aab507e4          
0x2AAB50840   ldr      x8, [x23, #0x10]     
0x2AAB50844   cmp      x22, x8              
0x2AAB50848   b.hs     0x2aab50b20          
0x2AAB5084C   ldur     x9, [x29, #-0xb0]    
0x2AAB50850   add      x8, x9, x22, lsl #5  
0x2AAB50854   ldr      x3, [x8, #0x18]      
0x2AAB50858   mov      x9, #0x7             
0x2AAB5085C   movk     x9, #0x7000, lsl #48 
0x2AAB50860   bics     xzr, x9, x3          
0x2AAB50864   b.ne     0x2aab508e4          
0x2AAB50868   mov      x0, x20              
0x2AAB5086C   mov      x1, x26              
0x2AAB50870   mov      x20, x27             
0x2AAB50874   bl       0x2aab73b00          
0x2AAB50878   tbz      w1, #0x0, 0x2aab507d8 
0x2AAB5087C   mov      x23, x0              
0x2AAB50880   mov      x0, x27              
0x2AAB50884   bl       0x2b00aace0          
0x2AAB50888   stur     x27, [x29, #-0x80]   
0x2AAB5088C   cbz      w0, 0x2aab50a30      
0x2AAB50890   ldr      x8, [x27, #0x30]     
0x2AAB50894   add      x9, x8, x23, lsl #4  
0x2AAB50898   ldr      x0, [x9, #0x8]       
0x2AAB5089C   bl       0x2b00aac30          
0x2AAB508A0   ldr      x8, [x27, #0x38]     
0x2AAB508A4   add      x9, x8, x23, lsl #5  
0x2AAB508A8   ldp      x20, x8, [x9]        
0x2AAB508AC   stur     x8, [x29, #-0xa0]    
0x2AAB508B0   ldp      x25, x28, [x9, #0x10] 
0x2AAB508B4   mov      x0, x23              
0x2AAB508B8   mov      x1, x27              
0x2AAB508BC   bl       0x2aab75c68          
0x2AAB508C0   mov      x0, x20              
0x2AAB508C4   ldur     x1, [x29, #-0xa0]    
0x2AAB508C8   mov      x2, x25              
0x2AAB508CC   mov      x3, x28              
0x2AAB508D0   bl       0x2aab2e844          
0x2AAB508D4   mov      x0, x26              
0x2AAB508D8   bl       0x2b00aac30          
0x2AAB508DC   ldur     x25, [x29, #-0xd8]   
0x2AAB508E0   b        0x2aab507e0          
0x2AAB508E4   ldp      q0, q1, [x8]         
0x2AAB508E8   stp      q0, q1, [x29, #-0xd0] 
0x2AAB508EC   ldp      x1, x2, [x8, #0x8]   
0x2AAB508F0   ldr      x0, [x8]             
0x2AAB508F4   stp      x0, x1, [x29, #-0x100] 
0x2AAB508F8   stur     x2, [x29, #-0xf0]    
0x2AAB508FC   stur     x3, [x29, #-0xe0]    
0x2AAB50900   bl       0x2aab2e82c          
0x2AAB50904   mov      x0, x27              
0x2AAB50908   bl       0x2b00aace0          
0x2AAB5090C   mov      x23, x0              
0x2AAB50910   stur     x27, [x29, #-0x80]   
0x2AAB50914   mov      x1, x26              
0x2AAB50918   mov      x26, x20             
0x2AAB5091C   mov      x0, x20              
0x2AAB50920   stur     x1, [x29, #-0xa0]    
0x2AAB50924   mov      x20, x27             
0x2AAB50928   bl       0x2aab73b00          
0x2AAB5092C   mov      x28, x0              
0x2AAB50930   mvn      w8, w1               
0x2AAB50934   and      x8, x8, #0x1         
0x2AAB50938   ldr      x9, [x27, #0x10]     
0x2AAB5093C   adds     x0, x9, x8           
0x2AAB50940   b.vs     0x2aab50b24          
0x2AAB50944   mov      x25, x1              
0x2AAB50948   ldr      x8, [x27, #0x18]     
0x2AAB5094C   cmp      x8, x0               
0x2AAB50950   b.ge     0x2aab50990          
0x2AAB50954   sub      x20, x29, #0x80      
0x2AAB50958   mov      x1, x23              
0x2AAB5095C   bl       0x2aab5b5cc          
0x2AAB50960   ldur     x20, [x29, #-0x80]   
0x2AAB50964   mov      x0, x26              
0x2AAB50968   ldur     x1, [x29, #-0xa0]    
0x2AAB5096C   bl       0x2aab73b00          
0x2AAB50970   and      w8, w1, #0x1         
0x2AAB50974   and      w9, w25, #0x1        
0x2AAB50978   cmp      w9, w8               
0x2AAB5097C   b.ne     0x2aab50b30          
0x2AAB50980   mov      x28, x0              
0x2AAB50984   ldur     x27, [x29, #-0x80]   
0x2AAB50988   tbnz     w25, #0x0, 0x2aab5099c 
0x2AAB5098C   b        0x2aab50a50          
0x2AAB50990   tbz      w23, #0x0, 0x2aab50a40 
0x2AAB50994   ldur     x27, [x29, #-0x80]   
0x2AAB50998   tbz      w25, #0x0, 0x2aab50a50 
0x2AAB5099C   ldr      x8, [x27, #0x38]     
0x2AAB509A0   add      x9, x8, x28, lsl #5  
0x2AAB509A4   ldp      x8, x28, [x9]        
0x2AAB509A8   sub      x10, x29, #0x8       
0x2AAB509AC   stur     x8, [x10, #-0x100]   
0x2AAB509B0   ldp      x11, x8, [x9, #0x10] 
0x2AAB509B4   sub      x10, x29, #0x10      
0x2AAB509B8   stur     x11, [x10, #-0x100]  
0x2AAB509BC   sub      x10, x29, #0x18      
0x2AAB509C0   stur     x8, [x10, #-0x100]   
0x2AAB509C4   ldp      q1, q0, [x29, #-0xd0] 
0x2AAB509C8   stp      q1, q0, [x9]         
0x2AAB509CC   ldp      x25, x23, [x29, #-0x100] 
0x2AAB509D0   mov      x0, x25              
0x2AAB509D4   mov      x1, x23              
0x2AAB509D8   ldur     x20, [x29, #-0xf0]   
0x2AAB509DC   mov      x2, x20              
0x2AAB509E0   ldur     x26, [x29, #-0xe0]   
0x2AAB509E4   mov      x3, x26              
0x2AAB509E8   bl       0x2aab2e82c          
0x2AAB509EC   sub      x8, x29, #0x8        
0x2AAB509F0   ldur     x0, [x8, #-0x100]    
0x2AAB509F4   mov      x1, x28              
0x2AAB509F8   sub      x8, x29, #0x10       
0x2AAB509FC   ldur     x2, [x8, #-0x100]    
0x2AAB50A00   sub      x8, x29, #0x18       
0x2AAB50A04   ldur     x3, [x8, #-0x100]    
0x2AAB50A08   bl       0x2aab2e844          
0x2AAB50A0C   ldur     x0, [x29, #-0xa0]    
0x2AAB50A10   bl       0x2b00aac30          
0x2AAB50A14   mov      x0, x25              
0x2AAB50A18   mov      x1, x23              
0x2AAB50A1C   mov      x2, x20              
0x2AAB50A20   mov      x3, x26              
0x2AAB50A24   bl       0x2aab2e968          
0x2AAB50A28   ldur     x25, [x29, #-0xd8]   
0x2AAB50A2C   b        0x2aab507e0          
0x2AAB50A30   sub      x20, x29, #0x80      
0x2AAB50A34   bl       0x2aab5d40c          
0x2AAB50A38   ldur     x27, [x29, #-0x80]   
0x2AAB50A3C   b        0x2aab50890          
0x2AAB50A40   sub      x20, x29, #0x80      
0x2AAB50A44   bl       0x2aab5d40c          
0x2AAB50A48   ldur     x27, [x29, #-0x80]   
0x2AAB50A4C   tbnz     w25, #0x0, 0x2aab5099c 
0x2AAB50A50   add      x8, x27, #0x40       
0x2AAB50A54   lsr      x9, x28, #3          
0x2AAB50A58   and      x9, x9, #0x1ffffffffffffff8 
0x2AAB50A5C   mov      w10, #0x1            
0x2AAB50A60   lsl      x10, x10, x28        
0x2AAB50A64   ldr      x11, [x8, x9]        
0x2AAB50A68   orr      x10, x11, x10        
0x2AAB50A6C   str      x10, [x8, x9]        
0x2AAB50A70   ldr      x8, [x27, #0x30]     
0x2AAB50A74   add      x9, x8, x28, lsl #4  
0x2AAB50A78   ldur     x8, [x29, #-0xa0]    
0x2AAB50A7C   stp      x26, x8, [x9]        
0x2AAB50A80   ldr      x8, [x27, #0x38]     
0x2AAB50A84   add      x9, x8, x28, lsl #5  
0x2AAB50A88   ldp      q0, q1, [x29, #-0xd0] 
0x2AAB50A8C   stp      q0, q1, [x9]         
0x2AAB50A90   ldr      x8, [x27, #0x10]     
0x2AAB50A94   adds     x8, x8, #0x1         
0x2AAB50A98   b.vs     0x2aab50b28          
0x2AAB50A9C   str      x8, [x27, #0x10]     
0x2AAB50AA0   ldur     x25, [x29, #-0xd8]   
0x2AAB50AA4   b        0x2aab507e0          
0x2AAB50AA8   mov      x0, x23              
0x2AAB50AAC   bl       0x2b00aac30          
0x2AAB50AB0   sub      x8, x29, #0x30       
0x2AAB50AB4   ldur     x28, [x8, #-0x100]   
0x2AAB50AB8   b        0x2aab50ac8          
0x2AAB50ABC   ldur     x0, [x29, #-0xa8]    
0x2AAB50AC0   bl       0x2b00aac30          
0x2AAB50AC4   ldur     x27, [x29, #-0x78]   
0x2AAB50AC8   ldur     x0, [x29, #-0x98]    
0x2AAB50ACC   bl       0x2aab51860          
0x2AAB50AD0   sub      x8, x29, #0x20       
0x2AAB50AD4   ldur     x22, [x8, #-0x100]   
0x2AAB50AD8   mov      x0, x22              
0x2AAB50ADC   bl       0x2b00aad00          
0x2AAB50AE0   mov      x0, x28              
0x2AAB50AE4   bl       0x2b00aac30          
0x2AAB50AE8   sub      x8, x29, #0x28       
0x2AAB50AEC   ldur     x0, [x8, #-0x100]    
0x2AAB50AF0   bl       0x2b00aac30          
0x2AAB50AF4   ldur     x20, [x29, #-0xe8]   
0x2AAB50AF8   ldr      x0, [x20, #0x18]     
0x2AAB50AFC   bl       0x2b00aac30          
0x2AAB50B00   ldr      x20, [x20, #0x30]    
0x2AAB50B04   mov      x0, x19              
0x2AAB50B08   bl       0x2b00aac30          
0x2AAB50B0C   mov      x0, x25              
0x2AAB50B10   bl       0x2b00aac30          
0x2AAB50B14   mov      x0, x20              
0x2AAB50B18   bl       0x2b00aad00          
0x2AAB50B1C   b        0x2aab50460          
0x2AAB50B20   brk      #0x1                 
0x2AAB50B24   brk      #0x1                 
0x2AAB50B28   brk      #0x1                 
0x2AAB50B2C   brk      #0x1                 
0x2AAB50B30   adrp     x0, 120394           ; 0x2c819a000
0x2AAB50B34   ldr      x0, [x0, #0x658]     
0x2AAB50B38   bl       0x2b00abe50          
0x2AAB50B3C   brk      #0x1                 
0x2AAB5677C   pacibsp                       
0x2AAB56780   sub      sp, sp, #0x100       
0x2AAB56784   stp      x28, x27, [sp, #0xa0] 
0x2AAB56788   stp      x26, x25, [sp, #0xb0] 
0x2AAB5678C   stp      x24, x23, [sp, #0xc0] 
0x2AAB56790   stp      x22, x21, [sp, #0xd0] 
0x2AAB56794   stp      x20, x19, [sp, #0xe0] 
0x2AAB56798   stp      x29, x30, [sp, #0xf0] 
0x2AAB5679C   add      x29, sp, #0xf0       
0x2AAB567A0   str      x0, [sp, #0x40]      
0x2AAB567A4   ldr      x20, [x0, #0x10]     
0x2AAB567A8   cbz      x20, 0x2aab567d8     
0x2AAB567AC   adrp     x0, 144463           ; 0x2cdfa5000
0x2AAB567B0   add      x0, x0, #0x858       
0x2AAB567B4   adrp     x1, 1311             ; 0x2ab075000
0x2AAB567B8   add      x1, x1, #0x698       
0x2AAB567BC   bl       0x2aab22034          
0x2AAB567C0   mov      x1, x0               
0x2AAB567C4   mov      x0, x20              
0x2AAB567C8   mov      x20, x1              
0x2AAB567CC   bl       0x2b00ae3c0          
0x2AAB567D0   mov      x20, x0              
0x2AAB567D4   b        0x2aab567e0          
0x2AAB567D8   adrp     x20, 120389          ; 0x2c819b000
0x2AAB567DC   ldr      x20, [x20, #0xfe8]   
0x2AAB567E0   ldr      x0, [sp, #0x40]      
0x2AAB567E4   mov      x9, x0               
0x2AAB567E8   ldr      x8, [x9, #0x40]!     
0x2AAB567EC   str      x9, [sp, #0x10]      
0x2AAB567F0   ldrb     w9, [x0, #0x20]      
0x2AAB567F4   and      x10, x9, #0x3f       
0x2AAB567F8   mov      w11, #0x1            
0x2AAB567FC   lsl      x9, x11, x9          
0x2AAB56800   mov      x11, #-0x1           
0x2AAB56804   lsl      x12, x11, x9         
0x2AAB56808   cmp      w10, #0x6            
0x2AAB5680C   csinv    x10, x11, x12, hs    
0x2AAB56810   and      x24, x10, x8         
0x2AAB56814   add      x8, x9, #0x3f        
0x2AAB56818   lsr      x8, x8, #6           
0x2AAB5681C   str      x8, [sp, #0x8]       
0x2AAB56820   add      x8, x20, #0x40       
0x2AAB56824   str      x8, [sp, #0x18]      
0x2AAB56828   bl       0x2b00abc60          
0x2AAB5682C   mov      x22, #0x0            
0x2AAB56830   cbnz     x24, 0x2aab5689c     
0x2AAB56834   b        0x2aab56874          
0x2AAB56838   ldr      x8, [x20, #0x30]     
0x2AAB5683C   add      x9, x8, x0, lsl #4   
0x2AAB56840   ldr      x8, [x9, #0x8]       
0x2AAB56844   stp      x19, x25, [x9]       
0x2AAB56848   mov      x25, x0              
0x2AAB5684C   mov      x0, x8               
0x2AAB56850   bl       0x2b00aac30          
0x2AAB56854   ldr      x8, [x20, #0x38]     
0x2AAB56858   add      x9, x8, x25, lsl #5  
0x2AAB5685C   ldp      x0, x1, [x9]         
0x2AAB56860   ldp      x2, x3, [x9, #0x10]  
0x2AAB56864   stp      x28, x27, [x9]       
0x2AAB56868   stp      x26, x21, [x9, #0x10] 
0x2AAB5686C   bl       0x2aab2e968          
0x2AAB56870   cbnz     x24, 0x2aab5689c     
0x2AAB56874   adds     x22, x22, #0x1       
0x2AAB56878   ldp      x9, x8, [sp, #0x8]   
0x2AAB5687C   b.vs     0x2aab569e0          
0x2AAB56880   cmp      x22, x9              
0x2AAB56884   b.ge     0x2aab569b4          
0x2AAB56888   ldr      x24, [x8, x22, lsl #3] 
0x2AAB5688C   cbnz     x24, 0x2aab5689c     
0x2AAB56890   adds     x22, x22, #0x1       
0x2AAB56894   b.vc     0x2aab56880          
0x2AAB56898   b        0x2aab569e0          
0x2AAB5689C   rbit     x8, x24              
0x2AAB568A0   clz      x8, x8               
0x2AAB568A4   sub      x9, x24, #0x1        
0x2AAB568A8   and      x24, x9, x24         
0x2AAB568AC   orr      x8, x8, x22, lsl #6  
0x2AAB568B0   ldr      x11, [sp, #0x40]     
0x2AAB568B4   ldr      x9, [x11, #0x30]     
0x2AAB568B8   add      x10, x9, x8, lsl #4  
0x2AAB568BC   ldp      x23, x25, [x10]      
0x2AAB568C0   ldr      x9, [x11, #0x38]     
0x2AAB568C4   add      x10, x9, x8, lsl #5  
0x2AAB568C8   ldp      q0, q1, [x10]        
0x2AAB568CC   ldp      x27, x26, [x10, #0x10] 
0x2AAB568D0   ldp      x21, x28, [x10]      
0x2AAB568D4   stur     q1, [sp, #0x58]      
0x2AAB568D8   stur     q0, [sp, #0x48]      
0x2AAB568DC   mov      x0, x25              
0x2AAB568E0   bl       0x2b00abc60          
0x2AAB568E4   mov      x0, x21              
0x2AAB568E8   mov      x1, x28              
0x2AAB568EC   mov      x2, x27              
0x2AAB568F0   mov      x3, x26              
0x2AAB568F4   bl       0x2aab2d56c          
0x2AAB568F8   adrp     x0, 150680           ; 0x2cf7ee000
0x2AAB568FC   add      x0, x0, #0xad0       
0x2AAB56900   adrp     x1, 1312             ; 0x2ab076000
0x2AAB56904   add      x1, x1, #0x5d0       
0x2AAB56908   bl       0x2aab22034          
0x2AAB5690C   mov      x3, x0               
0x2AAB56910   add      x8, sp, #0x68        
0x2AAB56914   add      x0, x8, #0x10        
0x2AAB56918   add      x1, sp, #0x48        
0x2AAB5691C   adrp     x2, 162680           ; 0x2d26ce000
0x2AAB56920   add      x2, x2, #0x748       
0x2AAB56924   mov      w4, #0x7             
0x2AAB56928   bl       0x2b00aac50          
0x2AAB5692C   ldur     q1, [sp, #0x88]      
0x2AAB56930   ldur     q0, [sp, #0x78]      
0x2AAB56934   stp      q1, q0, [sp, #0x20]  
0x2AAB56938   ldp      x26, x21, [sp, #0x88] 
0x2AAB5693C   ldp      x28, x27, [sp, #0x78] 
0x2AAB56940   mov      x19, x23             
0x2AAB56944   mov      x0, x23              
0x2AAB56948   mov      x1, x25              
0x2AAB5694C   bl       0x2aab73b00          
0x2AAB56950   tbnz     w1, #0x0, 0x2aab56838 
0x2AAB56954   ldp      x8, x9, [x20, #0x10] 
0x2AAB56958   cmp      x8, x9               
0x2AAB5695C   b.hs     0x2aab569e4          
0x2AAB56960   lsr      x8, x0, #3           
0x2AAB56964   and      x8, x8, #0x1ffffffffffffff8 
0x2AAB56968   mov      w9, #0x1             
0x2AAB5696C   lsl      x9, x9, x0           
0x2AAB56970   ldr      x11, [sp, #0x18]     
0x2AAB56974   ldr      x10, [x11, x8]       
0x2AAB56978   orr      x9, x10, x9          
0x2AAB5697C   str      x9, [x11, x8]        
0x2AAB56980   ldr      x8, [x20, #0x30]     
0x2AAB56984   add      x9, x8, x0, lsl #4   
0x2AAB56988   stp      x19, x25, [x9]       
0x2AAB5698C   ldr      x8, [x20, #0x38]     
0x2AAB56990   add      x9, x8, x0, lsl #5   
0x2AAB56994   ldp      q1, q0, [sp, #0x20]  
0x2AAB56998   stp      q0, q1, [x9]         
0x2AAB5699C   ldr      x8, [x20, #0x10]     
0x2AAB569A0   adds     x8, x8, #0x1         
0x2AAB569A4   b.vs     0x2aab569e8          
0x2AAB569A8   str      x8, [x20, #0x10]     
0x2AAB569AC   cbnz     x24, 0x2aab5689c     
0x2AAB569B0   b        0x2aab56874          
0x2AAB569B4   ldr      x0, [sp, #0x40]      
0x2AAB569B8   bl       0x2b00aad00          
0x2AAB569BC   mov      x0, x20              
0x2AAB569C0   ldp      x29, x30, [sp, #0xf0] 
0x2AAB569C4   ldp      x20, x19, [sp, #0xe0] 
0x2AAB569C8   ldp      x22, x21, [sp, #0xd0] 
0x2AAB569CC   ldp      x24, x23, [sp, #0xc0] 
0x2AAB569D0   ldp      x26, x25, [sp, #0xb0] 
0x2AAB569D4   ldp      x28, x27, [sp, #0xa0] 
0x2AAB569D8   add      sp, sp, #0x100       
0x2AAB569DC   retab                         
0x2AAB569E0   brk      #0x1                 
0x2AAB569E4   brk      #0x1                 
0x2AAB569E8   brk      #0x1                 
