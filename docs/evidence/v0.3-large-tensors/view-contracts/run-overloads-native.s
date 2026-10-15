0x2AAB5DB7C   pacibsp                       
0x2AAB5DB80   orr      x29, x29, #0x1000000000000000 
0x2AAB5DB84   str      x19, [sp, #-0x20]!   
0x2AAB5DB88   stp      x29, x30, [sp, #0x10] 
0x2AAB5DB8C   add      x16, sp, #0x8        
0x2AAB5DB90   movk     x16, #0xc31a, lsl #48 
0x2AAB5DB94   mov      x17, x22             
0x2AAB5DB98   pacdb    x17, x16             
0x2AAB5DB9C   str      x17, [sp, #0x8]      
0x2AAB5DBA0   add      x29, sp, #0x10       
0x2AAB5DBA4   mov      x19, x1              
0x2AAB5DBA8   stp      x3, x20, [x22, #0x20] 
0x2AAB5DBAC   stp      x0, x2, [x22, #0x10] 
0x2AAB5DBB0   adrp     x0, 144456           ; 0x2cdfa5000
0x2AAB5DBB4   add      x0, x0, #0x848       
0x2AAB5DBB8   adrp     x1, 1304             ; 0x2ab075000
0x2AAB5DBBC   add      x1, x1, #0x688       
0x2AAB5DBC0   bl       0x2aab22034          
0x2AAB5DBC4   ldr      x16, [x0, #-0x8]!    
0x2AAB5DBC8   mov      x17, x0              
0x2AAB5DBCC   movk     x17, #0x2e3f, lsl #48 
0x2AAB5DBD0   autda    x16, x17             
0x2AAB5DBD4   ldr      x8, [x16, #0x40]     
0x2AAB5DBD8   add      x8, x8, #0xf         
0x2AAB5DBDC   and      x0, x8, #0xfffffffffffffff0 
0x2AAB5DBE0   bl       0x2b00b2aa0          
0x2AAB5DBE4   str      x0, [x22, #0x30]     
0x2AAB5DBE8   mov      x0, #0x0             
0x2AAB5DBEC   bl       _$s13CoreAIRuntime22InferenceFunctionStateVMa 
0x2AAB5DBF0   str      x0, [x22, #0x38]     
0x2AAB5DBF4   ldr      x16, [x0, #-0x8]!    
0x2AAB5DBF8   mov      x17, x0              
0x2AAB5DBFC   movk     x17, #0x2e3f, lsl #48 
0x2AAB5DC00   autda    x16, x17             
0x2AAB5DC04   ldr      x8, [x16, #0x40]     
0x2AAB5DC08   add      x20, x8, #0xf        
0x2AAB5DC0C   and      x0, x20, #0xfffffffffffffff0 
0x2AAB5DC10   bl       0x2b00b2aa0          
0x2AAB5DC14   str      x0, [x22, #0x40]     
0x2AAB5DC18   and      x0, x20, #0xfffffffffffffff0 
0x2AAB5DC1C   bl       0x2b00b2aa0          
0x2AAB5DC20   ldr      x8, [x19]            
0x2AAB5DC24   stp      x0, x8, [x22, #0x48] 
0x2AAB5DC28   adrp     x16, 0               ; 0x2aab5d000
0x2AAB5DC2C   add      x16, x16, #0xc60     
0x2AAB5DC30   paciza   x16                  
0x2AAB5DC34   mov      x0, x16              
0x2AAB5DC38   mov      x1, #0x0             
0x2AAB5DC3C   mov      x2, #0x0             
0x2AAB5DC40   ldp      x29, x30, [sp, #0x10] 
0x2AAB5DC44   ldr      x19, [sp], #0x20     
0x2AAB5DC48   and      x29, x29, #0xefffffffffffffff 
0x2AAB5DC4C   autibsp                       
0x2AAB5DC50   eor      x16, x30, x30, lsl #1 
0x2AAB5DC54   tbz      x16, #0x3e, 0x2aab5dc5c 
0x2AAB5DC58   brk      #0xc471              
0x2AAB5DC5C   b        0x2b00b2ae0          
0x2AAB5DC60   pacibsp                       
0x2AAB5DC64   orr      x29, x29, #0x1000000000000000 
0x2AAB5DC68   sub      sp, sp, #0x60        
0x2AAB5DC6C   stp      x26, x25, [sp, #0x18] 
0x2AAB5DC70   stp      x24, x23, [sp, #0x28] 
0x2AAB5DC74   stp      x21, x19, [sp, #0x38] 
0x2AAB5DC78   stp      x29, x30, [sp, #0x50] 
0x2AAB5DC7C   add      x16, sp, #0x48       
0x2AAB5DC80   movk     x16, #0xc31a, lsl #48 
0x2AAB5DC84   mov      x17, x22             
0x2AAB5DC88   pacdb    x17, x16             
0x2AAB5DC8C   str      x17, [sp, #0x48]     
0x2AAB5DC90   add      x29, sp, #0x50       
0x2AAB5DC94   ldr      x8, [x22, #0x28]     
0x2AAB5DC98   ldr      x19, [x8, #0x8]      
0x2AAB5DC9C   str      x19, [x22, #0x58]    
0x2AAB5DCA0   ldr      x23, [x8]            
0x2AAB5DCA4   str      x23, [x22, #0x60]    
0x2AAB5DCA8   mov      x0, x19              
0x2AAB5DCAC   bl       0x2b00abd50          
0x2AAB5DCB0   add      x0, x23, #0x18       
0x2AAB5DCB4   bl       0x2b00abb90          
0x2AAB5DCB8   ldr      x8, [x23, #0x28]     
0x2AAB5DCBC   cbz      x8, 0x2aab5dd50      
0x2AAB5DCC0   ldr      x21, [x22, #0x40]    
0x2AAB5DCC4   ldr      x24, [x22, #0x30]    
0x2AAB5DCC8   sub      x0, x8, #0x1         
0x2AAB5DCCC   add      x20, x23, #0x20      
0x2AAB5DCD0   mov      x8, x21              
0x2AAB5DCD4   bl       0x2aab595e4          
0x2AAB5DCD8   mov      x0, x21              
0x2AAB5DCDC   mov      x1, x24              
0x2AAB5DCE0   bl       0x2aab52490          
0x2AAB5DCE4   ldp      x20, x26, [x22, #0x48] 
0x2AAB5DCE8   ldr      x21, [x22, #0x30]    
0x2AAB5DCEC   ldp      x25, x24, [x22, #0x18] 
0x2AAB5DCF0   add      x0, x23, #0x18       
0x2AAB5DCF4   bl       0x2b00abba0          
0x2AAB5DCF8   mov      x0, x21              
0x2AAB5DCFC   mov      x1, x20              
0x2AAB5DD00   bl       0x2aab52490          
0x2AAB5DD04   str      x26, [sp, #0x8]      
0x2AAB5DD08   add      x1, sp, #0x8         
0x2AAB5DD0C   mov      x0, #0x0             
0x2AAB5DD10   mov      x2, x25              
0x2AAB5DD14   mov      x3, x24              
0x2AAB5DD18   mov      w4, #0x1             
0x2AAB5DD1C   mov      x5, x19              
0x2AAB5DD20   mov      x21, #0x0            
0x2AAB5DD24   bl       0x2aab5015c          
0x2AAB5DD28   ldr      x20, [x22, #0x48]    
0x2AAB5DD2C   cbz      x21, 0x2aab5ddf8     
0x2AAB5DD30   mov      x24, x21             
0x2AAB5DD34   mov      x0, x20              
0x2AAB5DD38   mov      x20, x23             
0x2AAB5DD3C   bl       0x2aab5196c          
0x2AAB5DD40   bl       0x2b00abd90          
0x2AAB5DD44   mov      x0, x19              
0x2AAB5DD48   bl       0x2b00aad00          
0x2AAB5DD4C   b        0x2aab5dd9c          
0x2AAB5DD50   ldr      x20, [x23, #0x10]    
0x2AAB5DD54   ldp      x0, x1, [x23, #0x38] 
0x2AAB5DD58   ldr      x2, [x23, #0x48]     
0x2AAB5DD5C   adrp     x25, 120382          ; 0x2c819b000
0x2AAB5DD60   ldr      x25, [x25, #0xfe0]   
0x2AAB5DD64   mov      x3, x25              
0x2AAB5DD68   mov      x21, #0x0            
0x2AAB5DD6C   bl       0x2aab63cd8          
0x2AAB5DD70   cbz      x21, 0x2aab5de88     
0x2AAB5DD74   mov      x24, x21             
0x2AAB5DD78   ldp      x21, x20, [x22, #0x18] 
0x2AAB5DD7C   add      x0, x23, #0x18       
0x2AAB5DD80   bl       0x2b00abba0          
0x2AAB5DD84   mov      x0, x19              
0x2AAB5DD88   bl       0x2b00aad00          
0x2AAB5DD8C   ldr      x0, [x20]            
0x2AAB5DD90   bl       0x2b00aac30          
0x2AAB5DD94   ldr      x0, [x21]            
0x2AAB5DD98   bl       0x2b00aac30          
0x2AAB5DD9C   ldp      x20, x0, [x22, #0x40] 
0x2AAB5DDA0   ldr      x19, [x22, #0x30]    
0x2AAB5DDA4   bl       0x2b00b2ac0          
0x2AAB5DDA8   mov      x0, x20              
0x2AAB5DDAC   bl       0x2b00b2ac0          
0x2AAB5DDB0   mov      x0, x19              
0x2AAB5DDB4   bl       0x2b00b2ac0          
0x2AAB5DDB8   mov      x0, x22              
0x2AAB5DDBC   ldr      x1, [x0, #0x8]!      
0x2AAB5DDC0   mov      x20, x24             
0x2AAB5DDC4   ldp      x29, x30, [sp, #0x50] 
0x2AAB5DDC8   ldp      x21, x19, [sp, #0x38] 
0x2AAB5DDCC   ldp      x24, x23, [sp, #0x28] 
0x2AAB5DDD0   ldp      x26, x25, [sp, #0x18] 
0x2AAB5DDD4   and      x29, x29, #0xefffffffffffffff 
0x2AAB5DDD8   add      sp, sp, #0x60        
0x2AAB5DDDC   autibsp                       
0x2AAB5DDE0   eor      x16, x30, x30, lsl #1 
0x2AAB5DDE4   tbz      x16, #0x3e, 0x2aab5ddec 
0x2AAB5DDE8   brk      #0xc471              
0x2AAB5DDEC   mov      x16, x0              
0x2AAB5DDF0   movk     x16, #0xd707, lsl #48 
0x2AAB5DDF4   braa     x1, x16              
0x2AAB5DDF8   ldr      x8, [x22, #0x38]     
0x2AAB5DDFC   stp      x1, x0, [x22, #0x68] 
0x2AAB5DE00   ldrsw    x21, [x8, #0x1c]     
0x2AAB5DE04   adrp     x8, 1303             ; 0x2ab074000
0x2AAB5DE08   ldr      w0, [x8, #0xd3c]     
0x2AAB5DE0C   mov      x19, x1              
0x2AAB5DE10   bl       0x2b00b2aa0          
0x2AAB5DE14   mov      x17, x22             
0x2AAB5DE18   mov      x16, x0              
0x2AAB5DE1C   movk     x16, #0xbda2, lsl #48 
0x2AAB5DE20   str      x0, [x22, #0x78]     
0x2AAB5DE24   pacda    x17, x16             
0x2AAB5DE28   str      x17, [x0]            
0x2AAB5DE2C   add      x8, x0, #0x8         
0x2AAB5DE30   adrp     x16, 0               ; 0x2aab5d000
0x2AAB5DE34   add      x16, x16, #0xed8     
0x2AAB5DE38   mov      x17, x8              
0x2AAB5DE3C   movk     x17, #0xd707, lsl #48 
0x2AAB5DE40   pacia    x16, x17             
0x2AAB5DE44   str      x16, [x0, #0x8]      
0x2AAB5DE48   add      x1, x20, x21         
0x2AAB5DE4C   mov      x22, x0              
0x2AAB5DE50   mov      x0, x19              
0x2AAB5DE54   mov      x2, #0x0             
0x2AAB5DE58   mov      w3, #0x1             
0x2AAB5DE5C   ldp      x29, x30, [sp, #0x50] 
0x2AAB5DE60   ldp      x21, x19, [sp, #0x38] 
0x2AAB5DE64   ldp      x24, x23, [sp, #0x28] 
0x2AAB5DE68   ldp      x26, x25, [sp, #0x18] 
0x2AAB5DE6C   and      x29, x29, #0xefffffffffffffff 
0x2AAB5DE70   add      sp, sp, #0x60        
0x2AAB5DE74   autibsp                       
0x2AAB5DE78   eor      x16, x30, x30, lsl #1 
0x2AAB5DE7C   tbz      x16, #0x3e, 0x2aab5de84 
0x2AAB5DE80   brk      #0xc471              
0x2AAB5DE84   b        0x2aab4084c          
0x2AAB5DE88   ldp      x9, x21, [x22, #0x38] 
0x2AAB5DE8C   ldr      x24, [x22, #0x30]    
0x2AAB5DE90   adrp     x8, 150673           ; 0x2cf7ee000
0x2AAB5DE94   ldr      x10, [x8, #0x4f0]    
0x2AAB5DE98   add      x8, x23, x10         
0x2AAB5DE9C   stp      x0, xzr, [x21, #0x8] 
0x2AAB5DEA0   str      x20, [x21]           
0x2AAB5DEA4   ldrsw    x10, [x9, #0x20]     
0x2AAB5DEA8   add      x10, x21, x10        
0x2AAB5DEAC   str      x25, [x10]           
0x2AAB5DEB0   ldrsw    x9, [x9, #0x1c]      
0x2AAB5DEB4   add      x1, x21, x9          
0x2AAB5DEB8   mov      x0, x8               
0x2AAB5DEBC   bl       0x2aab5179c          
0x2AAB5DEC0   mov      x0, x21              
0x2AAB5DEC4   mov      x1, x24              
0x2AAB5DEC8   bl       0x2aab52490          
0x2AAB5DECC   mov      x0, x20              
0x2AAB5DED0   bl       0x2b00abd50          
0x2AAB5DED4   b        0x2aab5dce4          
0x2AAB5DED8   pacibsp                       
0x2AAB5DEDC   orr      x29, x29, #0x1000000000000000 
0x2AAB5DEE0   sub      sp, sp, #0x20        
0x2AAB5DEE4   stp      x29, x30, [sp, #0x10] 
0x2AAB5DEE8   add      x16, sp, #0x8        
0x2AAB5DEEC   movk     x16, #0xc31a, lsl #48 
0x2AAB5DEF0   mov      x17, x22             
0x2AAB5DEF4   pacdb    x17, x16             
0x2AAB5DEF8   str      x17, [sp, #0x8]      
0x2AAB5DEFC   add      x29, sp, #0x10       
0x2AAB5DF00   mov      x17, x22             
0x2AAB5DF04   sub      x8, x29, #0x8        
0x2AAB5DF08   movk     x8, #0xc31a, lsl #48 
0x2AAB5DF0C   ldr      x9, [x22]            
0x2AAB5DF10   mov      x16, x9              
0x2AAB5DF14   movk     x17, #0xbda2, lsl #48 
0x2AAB5DF18   autda    x16, x17             
0x2AAB5DF1C   mov      x17, x16             
0x2AAB5DF20   xpacd    x17                  
0x2AAB5DF24   cmp      x16, x17             
0x2AAB5DF28   b.eq     0x2aab5df30          
0x2AAB5DF2C   brk      #0xc472              
0x2AAB5DF30   mov      x17, x16             
0x2AAB5DF34   mov      x16, x8              
0x2AAB5DF38   pacda    x17, x16             
0x2AAB5DF3C   sub      x8, x29, #0x8        
0x2AAB5DF40   str      x17, [x8]            
0x2AAB5DF44   mov      x16, x9              
0x2AAB5DF48   mov      x17, x22             
0x2AAB5DF4C   movk     x17, #0xbda2, lsl #48 
0x2AAB5DF50   autda    x16, x17             
0x2AAB5DF54   ldr      x0, [x16, #0x78]     
0x2AAB5DF58   ldr      x16, [x22]           
0x2AAB5DF5C   mov      x17, x22             
0x2AAB5DF60   movk     x17, #0xbda2, lsl #48 
0x2AAB5DF64   autda    x16, x17             
0x2AAB5DF68   mov      x17, x16             
0x2AAB5DF6C   xpacd    x17                  
0x2AAB5DF70   cmp      x16, x17             
0x2AAB5DF74   b.eq     0x2aab5df7c          
0x2AAB5DF78   brk      #0xc472              
0x2AAB5DF7C   mov      x22, x16             
0x2AAB5DF80   bl       0x2b00b2ac0          
0x2AAB5DF84   adrp     x16, 0               ; 0x2aab5d000
0x2AAB5DF88   add      x16, x16, #0xfbc     
0x2AAB5DF8C   paciza   x16                  
0x2AAB5DF90   mov      x0, x16              
0x2AAB5DF94   mov      x1, #0x0             
0x2AAB5DF98   mov      x2, #0x0             
0x2AAB5DF9C   ldp      x29, x30, [sp, #0x10] 
0x2AAB5DFA0   and      x29, x29, #0xefffffffffffffff 
0x2AAB5DFA4   add      sp, sp, #0x20        
0x2AAB5DFA8   autibsp                       
0x2AAB5DFAC   eor      x16, x30, x30, lsl #1 
0x2AAB5DFB0   tbz      x16, #0x3e, 0x2aab5dfb8 
0x2AAB5DFB4   brk      #0xc471              
0x2AAB5DFB8   b        0x2b00b2ae0          
0x2AAB5DFBC   pacibsp                       
0x2AAB5DFC0   orr      x29, x29, #0x1000000000000000 
0x2AAB5DFC4   sub      sp, sp, #0x60        
0x2AAB5DFC8   stp      x28, x27, [sp, #0x8] 
0x2AAB5DFCC   stp      x26, x25, [sp, #0x18] 
0x2AAB5DFD0   stp      x24, x23, [sp, #0x28] 
0x2AAB5DFD4   stp      x21, x19, [sp, #0x38] 
0x2AAB5DFD8   stp      x29, x30, [sp, #0x50] 
0x2AAB5DFDC   add      x16, sp, #0x48       
0x2AAB5DFE0   movk     x16, #0xc31a, lsl #48 
0x2AAB5DFE4   mov      x17, x22             
0x2AAB5DFE8   pacdb    x17, x16             
0x2AAB5DFEC   str      x17, [sp, #0x48]     
0x2AAB5DFF0   add      x29, sp, #0x50       
0x2AAB5DFF4   ldp      x19, x21, [x22, #0x68] 
0x2AAB5DFF8   ldp      x23, x20, [x22, #0x58] 
0x2AAB5DFFC   ldp      x25, x24, [x22, #0x40] 
0x2AAB5E000   ldr      x26, [x22, #0x30]    
0x2AAB5E004   ldr      x28, [x22, #0x10]    
0x2AAB5E008   mov      x0, x21              
0x2AAB5E00C   bl       0x2aab5677c          
0x2AAB5E010   mov      x27, x0              
0x2AAB5E014   mov      x0, x21              
0x2AAB5E018   bl       0x2b00aac30          
0x2AAB5E01C   mov      x0, x19              
0x2AAB5E020   bl       0x2b00aad00          
0x2AAB5E024   mov      x0, x24              
0x2AAB5E028   bl       0x2aab5196c          
0x2AAB5E02C   mov      x0, x23              
0x2AAB5E030   bl       0x2b00aad00          
0x2AAB5E034   str      x27, [x28]           
0x2AAB5E038   mov      x0, x24              
0x2AAB5E03C   bl       0x2b00b2ac0          
0x2AAB5E040   mov      x0, x25              
0x2AAB5E044   bl       0x2b00b2ac0          
0x2AAB5E048   mov      x0, x26              
0x2AAB5E04C   bl       0x2b00b2ac0          
0x2AAB5E050   mov      x0, x22              
0x2AAB5E054   ldr      x1, [x0, #0x8]!      
0x2AAB5E058   mov      x20, #0x0            
0x2AAB5E05C   ldp      x29, x30, [sp, #0x50] 
0x2AAB5E060   ldp      x21, x19, [sp, #0x38] 
0x2AAB5E064   ldp      x24, x23, [sp, #0x28] 
0x2AAB5E068   ldp      x26, x25, [sp, #0x18] 
0x2AAB5E06C   ldp      x28, x27, [sp, #0x8] 
0x2AAB5E070   and      x29, x29, #0xefffffffffffffff 
0x2AAB5E074   add      sp, sp, #0x60        
0x2AAB5E078   autibsp                       
0x2AAB5E07C   eor      x16, x30, x30, lsl #1 
0x2AAB5E080   tbz      x16, #0x3e, 0x2aab5e088 
0x2AAB5E084   brk      #0xc471              
0x2AAB5E088   mov      x16, x0              
0x2AAB5E08C   movk     x16, #0xd707, lsl #48 
0x2AAB5E090   braa     x1, x16              
0x2AAB5E094   pacibsp                       
0x2AAB5E098   orr      x29, x29, #0x1000000000000000 
0x2AAB5E09C   sub      sp, sp, #0x40        
0x2AAB5E0A0   stp      x24, x23, [sp, #0x8] 
0x2AAB5E0A4   stp      x21, x19, [sp, #0x18] 
0x2AAB5E0A8   stp      x29, x30, [sp, #0x30] 
0x2AAB5E0AC   add      x16, sp, #0x28       
0x2AAB5E0B0   movk     x16, #0xc31a, lsl #48 
0x2AAB5E0B4   mov      x17, x22             
0x2AAB5E0B8   pacdb    x17, x16             
0x2AAB5E0BC   str      x17, [sp, #0x28]     
0x2AAB5E0C0   add      x29, sp, #0x30       
0x2AAB5E0C4   mov      x19, x3              
0x2AAB5E0C8   mov      x21, x2              
0x2AAB5E0CC   mov      x23, x1              
0x2AAB5E0D0   mov      x24, x0              
0x2AAB5E0D4   adrp     x8, 1303             ; 0x2ab075000
0x2AAB5E0D8   ldr      w0, [x8, #0x704]     
0x2AAB5E0DC   bl       0x2b00b2aa0          
0x2AAB5E0E0   mov      x8, x0               
0x2AAB5E0E4   mov      x17, x22             
0x2AAB5E0E8   mov      x16, x0              
0x2AAB5E0EC   movk     x16, #0xbda2, lsl #48 
0x2AAB5E0F0   str      x0, [x22, #0x10]     
0x2AAB5E0F4   pacda    x17, x16             
0x2AAB5E0F8   str      x17, [x0]            
0x2AAB5E0FC   add      x9, x0, #0x8         
0x2AAB5E100   adrp     x16, 0               ; 0x2aab5e000
0x2AAB5E104   add      x16, x16, #0x15c     
0x2AAB5E108   mov      x17, x9              
0x2AAB5E10C   movk     x17, #0xd707, lsl #48 
0x2AAB5E110   pacia    x16, x17             
0x2AAB5E114   str      x16, [x0, #0x8]      
0x2AAB5E118   mov      x0, x24              
0x2AAB5E11C   mov      x22, x8              
0x2AAB5E120   mov      x1, x23              
0x2AAB5E124   mov      x2, x21              
0x2AAB5E128   mov      x3, x19              
0x2AAB5E12C   mov      w4, #0x1             
0x2AAB5E130   mov      x5, #0x0             
0x2AAB5E134   ldp      x29, x30, [sp, #0x30] 
0x2AAB5E138   ldp      x21, x19, [sp, #0x18] 
0x2AAB5E13C   ldp      x24, x23, [sp, #0x8] 
0x2AAB5E140   and      x29, x29, #0xefffffffffffffff 
0x2AAB5E144   add      sp, sp, #0x40        
0x2AAB5E148   autibsp                       
0x2AAB5E14C   eor      x16, x30, x30, lsl #1 
0x2AAB5E150   tbz      x16, #0x3e, 0x2aab5e158 
0x2AAB5E154   brk      #0xc471              
0x2AAB5E158   b        0x2aab5e250          
0x2AAB5E15C   pacibsp                       
0x2AAB5E160   orr      x29, x29, #0x1000000000000000 
0x2AAB5E164   sub      sp, sp, #0x30        
0x2AAB5E168   stp      x21, x19, [sp, #0x8] 
0x2AAB5E16C   stp      x29, x30, [sp, #0x20] 
0x2AAB5E170   add      x16, sp, #0x18       
0x2AAB5E174   movk     x16, #0xc31a, lsl #48 
0x2AAB5E178   mov      x17, x22             
0x2AAB5E17C   pacdb    x17, x16             
0x2AAB5E180   str      x17, [sp, #0x18]     
0x2AAB5E184   add      x29, sp, #0x20       
0x2AAB5E188   mov      x17, x22             
0x2AAB5E18C   sub      x8, x29, #0x8        
0x2AAB5E190   movk     x8, #0xc31a, lsl #48 
0x2AAB5E194   ldr      x9, [x22]            
0x2AAB5E198   mov      x16, x9              
0x2AAB5E19C   movk     x17, #0xbda2, lsl #48 
0x2AAB5E1A0   autda    x16, x17             
0x2AAB5E1A4   mov      x17, x16             
0x2AAB5E1A8   xpacd    x17                  
0x2AAB5E1AC   cmp      x16, x17             
0x2AAB5E1B0   b.eq     0x2aab5e1b8          
0x2AAB5E1B4   brk      #0xc472              
0x2AAB5E1B8   mov      x17, x16             
0x2AAB5E1BC   mov      x16, x8              
0x2AAB5E1C0   pacda    x17, x16             
0x2AAB5E1C4   sub      x8, x29, #0x8        
0x2AAB5E1C8   str      x17, [x8]            
0x2AAB5E1CC   mov      x16, x9              
0x2AAB5E1D0   mov      x17, x22             
0x2AAB5E1D4   movk     x17, #0xbda2, lsl #48 
0x2AAB5E1D8   autda    x16, x17             
0x2AAB5E1DC   ldr      x0, [x16, #0x10]     
0x2AAB5E1E0   ldr      x21, [x22]           
0x2AAB5E1E4   mov      x16, x21             
0x2AAB5E1E8   mov      x17, x22             
0x2AAB5E1EC   movk     x17, #0xbda2, lsl #48 
0x2AAB5E1F0   autda    x16, x17             
0x2AAB5E1F4   mov      x17, x16             
0x2AAB5E1F8   xpacd    x17                  
0x2AAB5E1FC   cmp      x16, x17             
0x2AAB5E200   b.eq     0x2aab5e208          
0x2AAB5E204   brk      #0xc472              
0x2AAB5E208   mov      x19, x16             
0x2AAB5E20C   bl       0x2b00b2ac0          
0x2AAB5E210   mov      x16, x21             
0x2AAB5E214   mov      x17, x22             
0x2AAB5E218   movk     x17, #0xbda2, lsl #48 
0x2AAB5E21C   autda    x16, x17             
0x2AAB5E220   ldr      x0, [x16, #0x8]!     
0x2AAB5E224   movk     x16, #0xd707, lsl #48 
0x2AAB5E228   mov      x22, x19             
0x2AAB5E22C   ldp      x29, x30, [sp, #0x20] 
0x2AAB5E230   ldp      x21, x19, [sp, #0x8] 
0x2AAB5E234   and      x29, x29, #0xefffffffffffffff 
0x2AAB5E238   add      sp, sp, #0x30        
0x2AAB5E23C   autibsp                       
0x2AAB5E240   eor      x17, x30, x30, lsl #1 
0x2AAB5E244   tbz      x17, #0x3e, 0x2aab5e24c 
0x2AAB5E248   brk      #0xc471              
0x2AAB5E24C   braa     x0, x16              
0x2AAB5E250   pacibsp                       
0x2AAB5E254   orr      x29, x29, #0x1000000000000000 
0x2AAB5E258   sub      sp, sp, #0x20        
0x2AAB5E25C   stp      x29, x30, [sp, #0x10] 
0x2AAB5E260   add      x16, sp, #0x8        
0x2AAB5E264   movk     x16, #0xc31a, lsl #48 
0x2AAB5E268   mov      x17, x22             
0x2AAB5E26C   pacdb    x17, x16             
0x2AAB5E270   str      x17, [sp, #0x8]      
0x2AAB5E274   add      x29, sp, #0x10       
0x2AAB5E278   adrp     x8, 120383           ; 0x2c819d000
0x2AAB5E27C   ldr      x8, [x8, #0x820]     
0x2AAB5E280   ldr      x8, [x8]             
0x2AAB5E284   str      x8, [sp]             
0x2AAB5E288   str      x20, [x22, #0x358]   
0x2AAB5E28C   str      x5, [x22, #0x350]    
0x2AAB5E290   str      w4, [x22, #0x3b0]    
0x2AAB5E294   str      x3, [x22, #0x348]    
0x2AAB5E298   str      x2, [x22, #0x340]    
0x2AAB5E29C   str      x1, [x22, #0x338]    
0x2AAB5E2A0   str      x0, [x22, #0x330]    
0x2AAB5E2A4   adrp     x0, 144455           ; 0x2cdfa5000
0x2AAB5E2A8   add      x0, x0, #0x848       
0x2AAB5E2AC   adrp     x1, 1303             ; 0x2ab075000
0x2AAB5E2B0   add      x1, x1, #0x688       
0x2AAB5E2B4   bl       0x2aab22034          
0x2AAB5E2B8   ldr      x16, [x0, #-0x8]!    
0x2AAB5E2BC   mov      x17, x0              
0x2AAB5E2C0   movk     x17, #0x2e3f, lsl #48 
0x2AAB5E2C4   autda    x16, x17             
0x2AAB5E2C8   ldr      x8, [x16, #0x40]     
0x2AAB5E2CC   add      x8, x8, #0xf         
0x2AAB5E2D0   and      x0, x8, #0xfffffffffffffff0 
0x2AAB5E2D4   bl       0x2b00b2aa0          
0x2AAB5E2D8   str      x0, [x22, #0x360]    
0x2AAB5E2DC   mov      x0, #0x0             
0x2AAB5E2E0   bl       _$s13CoreAIRuntime22InferenceFunctionStateVMa 
0x2AAB5E2E4   str      x0, [x22, #0x368]    
0x2AAB5E2E8   ldr      x16, [x0, #-0x8]!    
0x2AAB5E2EC   mov      x17, x0              
0x2AAB5E2F0   movk     x17, #0x2e3f, lsl #48 
0x2AAB5E2F4   autda    x16, x17             
0x2AAB5E2F8   ldr      x8, [x16, #0x40]     
0x2AAB5E2FC   add      x20, x8, #0xf        
0x2AAB5E300   and      x0, x20, #0xfffffffffffffff0 
0x2AAB5E304   bl       0x2b00b2aa0          
0x2AAB5E308   str      x0, [x22, #0x370]    
0x2AAB5E30C   and      x0, x20, #0xfffffffffffffff0 
0x2AAB5E310   bl       0x2b00b2aa0          
0x2AAB5E314   adrp     x8, 120383           ; 0x2c819d000
0x2AAB5E318   ldr      x8, [x8, #0x820]     
0x2AAB5E31C   ldr      x8, [x8]             
0x2AAB5E320   str      x0, [x22, #0x378]    
0x2AAB5E324   adrp     x16, 0               ; 0x2aab5e000
0x2AAB5E328   add      x16, x16, #0x36c     
0x2AAB5E32C   paciza   x16                  
0x2AAB5E330   ldr      x9, [sp]             
0x2AAB5E334   cmp      x8, x9               
0x2AAB5E338   b.ne     0x2aab5e368          
0x2AAB5E33C   mov      x0, x16              
0x2AAB5E340   mov      x1, #0x0             
0x2AAB5E344   mov      x2, #0x0             
0x2AAB5E348   ldp      x29, x30, [sp, #0x10] 
0x2AAB5E34C   and      x29, x29, #0xefffffffffffffff 
0x2AAB5E350   add      sp, sp, #0x20        
0x2AAB5E354   autibsp                       
0x2AAB5E358   eor      x16, x30, x30, lsl #1 
0x2AAB5E35C   tbz      x16, #0x3e, 0x2aab5e364 
0x2AAB5E360   brk      #0xc471              
0x2AAB5E364   b        0x2b00b2ae0          
0x2AAB5E368   bl       0x2b00aa710          
0x2AAB5E36C   pacibsp                       
0x2AAB5E370   orr      x29, x29, #0x1000000000000000 
0x2AAB5E374   sub      sp, sp, #0x140       
0x2AAB5E378   stp      x28, x27, [sp, #0xe8] 
0x2AAB5E37C   stp      x26, x25, [sp, #0xf8] 
0x2AAB5E380   stp      x24, x23, [sp, #0x108] 
0x2AAB5E384   stp      x21, x19, [sp, #0x118] 
0x2AAB5E388   stp      x29, x30, [sp, #0x130] 
0x2AAB5E38C   add      x16, sp, #0x128      
0x2AAB5E390   movk     x16, #0xc31a, lsl #48 
0x2AAB5E394   mov      x17, x22             
0x2AAB5E398   pacdb    x17, x16             
0x2AAB5E39C   str      x17, [sp, #0x128]    
0x2AAB5E3A0   add      x29, sp, #0x130      
0x2AAB5E3A4   adrp     x8, 120383           ; 0x2c819d000
0x2AAB5E3A8   ldr      x8, [x8, #0x820]     
0x2AAB5E3AC   ldr      x8, [x8]             
0x2AAB5E3B0   stur     x8, [x29, #-0x58]    
0x2AAB5E3B4   add      x8, x22, #0xd8       
0x2AAB5E3B8   stur     x8, [x29, #-0x78]    
0x2AAB5E3BC   add      x8, x22, #0x1a0      
0x2AAB5E3C0   str      x8, [sp, #0x18]      
0x2AAB5E3C4   ldr      x19, [x22, #0x338]   
0x2AAB5E3C8   adrp     x0, 120381           ; 0x2c819b000
0x2AAB5E3CC   ldr      x0, [x0, #0xfe0]     
0x2AAB5E3D0   bl       0x2aab6f5a0          
0x2AAB5E3D4   mov      x20, x0              
0x2AAB5E3D8   mov      x9, x19              
0x2AAB5E3DC   ldr      x8, [x9, #0x40]!     
0x2AAB5E3E0   str      x9, [sp, #0x10]      
0x2AAB5E3E4   ldrb     w9, [x19, #0x20]     
0x2AAB5E3E8   mov      x10, #-0x1           
0x2AAB5E3EC   lsl      x9, x10, x9          
0x2AAB5E3F0   neg      x11, x9              
0x2AAB5E3F4   lsl      x12, x10, x11        
0x2AAB5E3F8   cmp      x11, #0x40           
0x2AAB5E3FC   csinv    x10, x10, x12, hs    
0x2AAB5E400   and      x23, x10, x8         
0x2AAB5E404   mov      w8, #0x3f            
0x2AAB5E408   sub      x8, x8, x9           
0x2AAB5E40C   lsr      x8, x8, #6           
0x2AAB5E410   str      x8, [sp, #0x8]       
0x2AAB5E414   str      x19, [sp, #0x20]     
0x2AAB5E418   mov      x0, x19              
0x2AAB5E41C   bl       0x2b00abc60          
0x2AAB5E420   mov      x25, #0x0            
0x2AAB5E424   b        0x2aab5e4d8          
0x2AAB5E428   ldur     x21, [x29, #-0x70]   
0x2AAB5E42C   mov      x0, x21              
0x2AAB5E430   bl       0x2b00aac30          
0x2AAB5E434   ldur     x20, [x29, #-0x68]   
0x2AAB5E438   ldr      x8, [x20, #0x38]     
0x2AAB5E43C   add      x9, x8, x27, lsl #5  
0x2AAB5E440   ldp      x0, x1, [x9]         
0x2AAB5E444   ldp      x2, x3, [x9, #0x10]  
0x2AAB5E448   stp      x28, xzr, [x9]       
0x2AAB5E44C   stp      xzr, x19, [x9, #0x10] 
0x2AAB5E450   bl       0x2aab2e844          
0x2AAB5E454   mov      x0, x21              
0x2AAB5E458   bl       0x2b00aac30          
0x2AAB5E45C   ldur     x19, [x29, #-0x88]   
0x2AAB5E460   mov      x0, x19              
0x2AAB5E464   bl       0x2b00aad00          
0x2AAB5E468   mov      x0, x26              
0x2AAB5E46C   bl       0x2b00aac30          
0x2AAB5E470   ldr      x27, [sp, #0x28]     
0x2AAB5E474   mov      x0, x27              
0x2AAB5E478   bl       0x2b00aac30          
0x2AAB5E47C   mov      x21, x26             
0x2AAB5E480   ldr      x26, [sp, #0x98]     
0x2AAB5E484   mov      x0, x26              
0x2AAB5E488   bl       0x2b00aac30          
0x2AAB5E48C   ldur     x24, [x29, #-0x90]   
0x2AAB5E490   mov      x0, x24              
0x2AAB5E494   bl       0x2b00aac30          
0x2AAB5E498   ldur     x0, [x29, #-0x78]    
0x2AAB5E49C   bl       0x2aab2d69c          
0x2AAB5E4A0   sub      x8, x23, #0x1        
0x2AAB5E4A4   and      x23, x8, x23         
0x2AAB5E4A8   mov      x0, #-0x8000000000000000 
0x2AAB5E4AC   bl       0x2b00aac30          
0x2AAB5E4B0   mov      x0, x19              
0x2AAB5E4B4   bl       0x2b00aad00          
0x2AAB5E4B8   mov      x0, x21              
0x2AAB5E4BC   bl       0x2b00aac30          
0x2AAB5E4C0   mov      x0, x27              
0x2AAB5E4C4   bl       0x2b00aac30          
0x2AAB5E4C8   mov      x0, x26              
0x2AAB5E4CC   bl       0x2b00aac30          
0x2AAB5E4D0   mov      x0, x24              
0x2AAB5E4D4   bl       0x2b00aac30          
0x2AAB5E4D8   str      x20, [x22, #0x380]   
0x2AAB5E4DC   cbz      x23, 0x2aab5e52c     
0x2AAB5E4E0   rbit     x8, x23              
0x2AAB5E4E4   clz      x8, x8               
0x2AAB5E4E8   orr      x8, x8, x25, lsl #6  
0x2AAB5E4EC   ldr      x11, [sp, #0x20]     
0x2AAB5E4F0   ldr      x10, [x11, #0x30]    
0x2AAB5E4F4   add      x9, x10, x8, lsl #4  
0x2AAB5E4F8   ldr      x10, [x11, #0x38]    
0x2AAB5E4FC   lsl      x11, x8, #6          
0x2AAB5E500   sub      x11, x11, x8, lsl #3 
0x2AAB5E504   add      x8, x10, x11         
0x2AAB5E508   ldr      x24, [x8]            
0x2AAB5E50C   ldrb     w10, [x24, #0x38]    
0x2AAB5E510   str      x20, [sp, #0x88]     
0x2AAB5E514   cbz      w10, 0x2aab5e554     
0x2AAB5E518   cmp      w10, #0x1            
0x2AAB5E51C   b.ne     0x2aab5e564          
0x2AAB5E520   add      x10, x24, #0x20      
0x2AAB5E524   mov      w12, #0x2            
0x2AAB5E528   b        0x2aab5e56c          
0x2AAB5E52C   adds     x25, x25, #0x1       
0x2AAB5E530   ldp      x9, x8, [sp, #0x8]   
0x2AAB5E534   b.vs     0x2aab5ef84          
0x2AAB5E538   cmp      x25, x9              
0x2AAB5E53C   b.ge     0x2aab5ec60          
0x2AAB5E540   ldr      x23, [x8, x25, lsl #3] 
0x2AAB5E544   cbnz     x23, 0x2aab5e4e0     
0x2AAB5E548   adds     x25, x25, #0x1       
0x2AAB5E54C   b.vc     0x2aab5e538          
0x2AAB5E550   b        0x2aab5ef84          
0x2AAB5E554   mov      w12, #0x0            
0x2AAB5E558   ldr      x10, [x24, #0x30]    
0x2AAB5E55C   add      x10, x10, #0x10      
0x2AAB5E560   b        0x2aab5e56c          
0x2AAB5E564   add      x10, x24, #0x28      
0x2AAB5E568   mov      w12, #0x1            
0x2AAB5E56C   ldp      x11, x0, [x9]        
0x2AAB5E570   stur     x11, [x29, #-0x80]   
0x2AAB5E574   ldp      x9, x26, [x8, #0x8]  
0x2AAB5E578   ldp      x27, x19, [x8, #0x18] 
0x2AAB5E57C   ldr      x21, [x8, #0x28]     
0x2AAB5E580   ldrb     w8, [x8, #0x30]      
0x2AAB5E584   ldr      x10, [x10]           
0x2AAB5E588   ldr      x20, [x26, #0x10]    
0x2AAB5E58C   cmp      x20, #0x6            
0x2AAB5E590   stur     x21, [x29, #-0x90]   
0x2AAB5E594   str      x26, [sp, #0x90]     
0x2AAB5E598   stur     x0, [x29, #-0x70]    
0x2AAB5E59C   stp      w8, w12, [sp, #0x80] 
0x2AAB5E5A0   stp      x10, x9, [sp, #0x70] 
0x2AAB5E5A4   b.lo     0x2aab5e60c          
0x2AAB5E5A8   mov      w1, #0x2             
0x2AAB5E5AC   bl       0x2b00ac8c0          
0x2AAB5E5B0   mov      x0, x24              
0x2AAB5E5B4   mov      w1, #0x2             
0x2AAB5E5B8   bl       0x2b00b0e10          
0x2AAB5E5BC   mov      x0, x26              
0x2AAB5E5C0   mov      w1, #0x3             
0x2AAB5E5C4   bl       0x2b00ac8c0          
0x2AAB5E5C8   mov      x0, x27              
0x2AAB5E5CC   mov      w1, #0x2             
0x2AAB5E5D0   bl       0x2b00ac8c0          
0x2AAB5E5D4   mov      x0, x19              
0x2AAB5E5D8   mov      w1, #0x2             
0x2AAB5E5DC   bl       0x2b00ac8c0          
0x2AAB5E5E0   mov      x0, x21              
0x2AAB5E5E4   mov      w1, #0x2             
0x2AAB5E5E8   bl       0x2b00ac8c0          
0x2AAB5E5EC   mov      x10, #0x0            
0x2AAB5E5F0   mov      x11, #0x0            
0x2AAB5E5F4   mov      x12, #0x0            
0x2AAB5E5F8   mov      x13, #0x0            
0x2AAB5E5FC   mov      x15, #0x0            
0x2AAB5E600   mov      w14, #0x1            
0x2AAB5E604   mov      x21, x26             
0x2AAB5E608   b        0x2aab5e6b8          
0x2AAB5E60C   mov      x21, x26             
0x2AAB5E610   mov      x26, x27             
0x2AAB5E614   mov      x27, x19             
0x2AAB5E618   add      x19, x21, #0x20      
0x2AAB5E61C   tst      x19, #0x7            
0x2AAB5E620   b.ne     0x2aab5ef8c          
0x2AAB5E624   mov      w1, #0x2             
0x2AAB5E628   bl       0x2b00ac8c0          
0x2AAB5E62C   mov      x0, x24              
0x2AAB5E630   mov      w1, #0x2             
0x2AAB5E634   bl       0x2b00b0e10          
0x2AAB5E638   mov      x0, x21              
0x2AAB5E63C   mov      w1, #0x2             
0x2AAB5E640   bl       0x2b00ac8c0          
0x2AAB5E644   mov      x0, x26              
0x2AAB5E648   mov      w1, #0x2             
0x2AAB5E64C   bl       0x2b00ac8c0          
0x2AAB5E650   mov      x0, x27              
0x2AAB5E654   mov      w1, #0x2             
0x2AAB5E658   bl       0x2b00ac8c0          
0x2AAB5E65C   ldur     x0, [x29, #-0x90]    
0x2AAB5E660   mov      w1, #0x2             
0x2AAB5E664   bl       0x2b00ac8c0          
0x2AAB5E668   cbz      x20, 0x2aab5e694     
0x2AAB5E66C   ldr      x21, [x19]           
0x2AAB5E670   cmp      x20, #0x1            
0x2AAB5E674   b.ne     0x2aab5e75c          
0x2AAB5E678   mov      x10, #0x0            
0x2AAB5E67C   mov      x11, #0x0            
0x2AAB5E680   mov      x12, #0x0            
0x2AAB5E684   mov      x13, #0x0            
0x2AAB5E688   mov      w14, #0x0            
0x2AAB5E68C   mov      w15, #0x1            
0x2AAB5E690   b        0x2aab5e6b0          
0x2AAB5E694   mov      x21, #0x0            
0x2AAB5E698   mov      x10, #0x0            
0x2AAB5E69C   mov      x11, #0x0            
0x2AAB5E6A0   mov      x12, #0x0            
0x2AAB5E6A4   mov      x13, #0x0            
0x2AAB5E6A8   mov      x15, #0x0            
0x2AAB5E6AC   mov      w14, #0x0            
0x2AAB5E6B0   mov      x19, x27             
0x2AAB5E6B4   mov      x27, x26             
0x2AAB5E6B8   ldr      x8, [x27, #0x10]     
0x2AAB5E6BC   cmp      x8, #0x6             
0x2AAB5E6C0   stur     x24, [x29, #-0x88]   
0x2AAB5E6C4   str      x27, [sp, #0x28]     
0x2AAB5E6C8   stp      x11, x10, [sp, #0x60] 
0x2AAB5E6CC   stp      x13, x12, [sp, #0x50] 
0x2AAB5E6D0   str      w14, [sp, #0x4c]     
0x2AAB5E6D4   stp      x21, x15, [sp, #0x38] 
0x2AAB5E6D8   b.lo     0x2aab5e704          
0x2AAB5E6DC   mov      x0, x27              
0x2AAB5E6E0   bl       0x2b00abc60          
0x2AAB5E6E4   mov      x17, #0x0            
0x2AAB5E6E8   mov      x0, #0x0             
0x2AAB5E6EC   mov      x24, #0x0            
0x2AAB5E6F0   mov      x2, #0x0             
0x2AAB5E6F4   mov      x28, #0x0            
0x2AAB5E6F8   mov      w20, #0x1            
0x2AAB5E6FC   mov      x16, x27             
0x2AAB5E700   b        0x2aab5e844          
0x2AAB5E704   add      x9, x27, #0x20       
0x2AAB5E708   tst      x9, #0x7             
0x2AAB5E70C   b.ne     0x2aab5ef90          
0x2AAB5E710   cbz      x8, 0x2aab5e73c      
0x2AAB5E714   ldr      x16, [x9]            
0x2AAB5E718   cmp      x8, #0x1             
0x2AAB5E71C   b.ne     0x2aab5e788          
0x2AAB5E720   mov      x17, #0x0            
0x2AAB5E724   mov      x0, #0x0             
0x2AAB5E728   mov      x24, #0x0            
0x2AAB5E72C   mov      x2, #0x0             
0x2AAB5E730   mov      w20, #0x0            
0x2AAB5E734   mov      w28, #0x1            
0x2AAB5E738   b        0x2aab5e844          
0x2AAB5E73C   mov      x16, #0x0            
0x2AAB5E740   mov      x17, #0x0            
0x2AAB5E744   mov      x0, #0x0             
0x2AAB5E748   mov      x24, #0x0            
0x2AAB5E74C   mov      x2, #0x0             
0x2AAB5E750   mov      x28, #0x0            
0x2AAB5E754   mov      w20, #0x0            
0x2AAB5E758   b        0x2aab5e844          
0x2AAB5E75C   ldr      x8, [sp, #0x90]      
0x2AAB5E760   ldr      x10, [x8, #0x28]     
0x2AAB5E764   cmp      x20, #0x2            
0x2AAB5E768   mov      x19, x27             
0x2AAB5E76C   b.ne     0x2aab5e7ac          
0x2AAB5E770   mov      x11, #0x0            
0x2AAB5E774   mov      x12, #0x0            
0x2AAB5E778   mov      x13, #0x0            
0x2AAB5E77C   mov      w14, #0x0            
0x2AAB5E780   mov      w15, #0x2            
0x2AAB5E784   b        0x2aab5e6b4          
0x2AAB5E788   ldr      x17, [x27, #0x28]    
0x2AAB5E78C   cmp      x8, #0x2             
0x2AAB5E790   b.ne     0x2aab5e7d0          
0x2AAB5E794   mov      x0, #0x0             
0x2AAB5E798   mov      x24, #0x0            
0x2AAB5E79C   mov      x2, #0x0             
0x2AAB5E7A0   mov      w20, #0x0            
0x2AAB5E7A4   mov      w28, #0x2            
0x2AAB5E7A8   b        0x2aab5e844          
0x2AAB5E7AC   ldr      x11, [x8, #0x30]     
0x2AAB5E7B0   cmp      x20, #0x3            
0x2AAB5E7B4   mov      x27, x26             
0x2AAB5E7B8   b.ne     0x2aab5e7f0          
0x2AAB5E7BC   mov      x12, #0x0            
0x2AAB5E7C0   mov      x13, #0x0            
0x2AAB5E7C4   mov      w14, #0x0            
0x2AAB5E7C8   mov      w15, #0x3            
0x2AAB5E7CC   b        0x2aab5e6b8          
0x2AAB5E7D0   ldr      x0, [x27, #0x30]     
0x2AAB5E7D4   cmp      x8, #0x3             
0x2AAB5E7D8   b.ne     0x2aab5e80c          
0x2AAB5E7DC   mov      x24, #0x0            
0x2AAB5E7E0   mov      x2, #0x0             
0x2AAB5E7E4   mov      w20, #0x0            
0x2AAB5E7E8   mov      w28, #0x3            
0x2AAB5E7EC   b        0x2aab5e844          
0x2AAB5E7F0   ldr      x12, [x8, #0x38]     
0x2AAB5E7F4   cmp      x20, #0x4            
0x2AAB5E7F8   b.ne     0x2aab5e828          
0x2AAB5E7FC   mov      x13, #0x0            
0x2AAB5E800   mov      w14, #0x0            
0x2AAB5E804   mov      w15, #0x4            
0x2AAB5E808   b        0x2aab5e6b8          
0x2AAB5E80C   ldr      x24, [x27, #0x38]    
0x2AAB5E810   cmp      x8, #0x4             
0x2AAB5E814   b.ne     0x2aab5e838          
0x2AAB5E818   mov      x2, #0x0             
0x2AAB5E81C   mov      w20, #0x0            
0x2AAB5E820   mov      w28, #0x4            
0x2AAB5E824   b        0x2aab5e844          
0x2AAB5E828   mov      w14, #0x0            
0x2AAB5E82C   mov      w15, #0x5            
0x2AAB5E830   ldr      x13, [x8, #0x40]     
0x2AAB5E834   b        0x2aab5e6b8          
0x2AAB5E838   mov      w20, #0x0            
0x2AAB5E83C   mov      w28, #0x5            
0x2AAB5E840   ldr      x2, [x27, #0x40]     
0x2AAB5E844   ldr      x12, [x19, #0x10]    
0x2AAB5E848   cmp      x12, #0x6            
0x2AAB5E84C   str      x23, [sp, #0x30]     
0x2AAB5E850   b.lo     0x2aab5e8ac          
0x2AAB5E854   mov      x27, x0              
0x2AAB5E858   mov      x0, x19              
0x2AAB5E85C   mov      x26, x16             
0x2AAB5E860   mov      x21, x17             
0x2AAB5E864   mov      x23, x19             
0x2AAB5E868   mov      x19, x20             
0x2AAB5E86C   mov      x20, x2              
0x2AAB5E870   bl       0x2b00abc60          
0x2AAB5E874   mov      x2, x20              
0x2AAB5E878   mov      x20, x19             
0x2AAB5E87C   mov      x19, x23             
0x2AAB5E880   mov      x0, x27              
0x2AAB5E884   mov      x17, x21             
0x2AAB5E888   mov      x16, x26             
0x2AAB5E88C   mov      x9, #0x0             
0x2AAB5E890   mov      x10, #0x0            
0x2AAB5E894   mov      x11, #0x0            
0x2AAB5E898   mov      x12, #0x0            
0x2AAB5E89C   mov      x14, #0x0            
0x2AAB5E8A0   mov      w13, #0x1            
0x2AAB5E8A4   mov      x8, x23              
0x2AAB5E8A8   b        0x2aab5e96c          
0x2AAB5E8AC   add      x8, x19, #0x20       
0x2AAB5E8B0   tst      x8, #0x7             
0x2AAB5E8B4   b.ne     0x2aab5ef94          
0x2AAB5E8B8   cbz      x12, 0x2aab5e8e4     
0x2AAB5E8BC   ldr      x8, [x8]             
0x2AAB5E8C0   cmp      x12, #0x1            
0x2AAB5E8C4   b.ne     0x2aab5e900          
0x2AAB5E8C8   mov      x9, #0x0             
0x2AAB5E8CC   mov      x10, #0x0            
0x2AAB5E8D0   mov      x11, #0x0            
0x2AAB5E8D4   mov      x12, #0x0            
0x2AAB5E8D8   mov      w13, #0x0            
0x2AAB5E8DC   mov      w14, #0x1            
0x2AAB5E8E0   b        0x2aab5e96c          
0x2AAB5E8E4   mov      x8, #0x0             
0x2AAB5E8E8   mov      x9, #0x0             
0x2AAB5E8EC   mov      x10, #0x0            
0x2AAB5E8F0   mov      x11, #0x0            
0x2AAB5E8F4   mov      x14, #0x0            
0x2AAB5E8F8   mov      w13, #0x0            
0x2AAB5E8FC   b        0x2aab5e96c          
0x2AAB5E900   ldr      x9, [x19, #0x28]     
0x2AAB5E904   cmp      x12, #0x2            
0x2AAB5E908   b.ne     0x2aab5e924          
0x2AAB5E90C   mov      x10, #0x0            
0x2AAB5E910   mov      x11, #0x0            
0x2AAB5E914   mov      x12, #0x0            
0x2AAB5E918   mov      w13, #0x0            
0x2AAB5E91C   mov      w14, #0x2            
0x2AAB5E920   b        0x2aab5e96c          
0x2AAB5E924   ldr      x10, [x19, #0x30]    
0x2AAB5E928   cmp      x12, #0x3            
0x2AAB5E92C   b.ne     0x2aab5e944          
0x2AAB5E930   mov      x11, #0x0            
0x2AAB5E934   mov      x12, #0x0            
0x2AAB5E938   mov      w13, #0x0            
0x2AAB5E93C   mov      w14, #0x3            
0x2AAB5E940   b        0x2aab5e96c          
0x2AAB5E944   ldr      x11, [x19, #0x38]    
0x2AAB5E948   cmp      x12, #0x4            
0x2AAB5E94C   b.ne     0x2aab5e960          
0x2AAB5E950   mov      x12, #0x0            
0x2AAB5E954   mov      w13, #0x0            
0x2AAB5E958   mov      w14, #0x4            
0x2AAB5E95C   b        0x2aab5e96c          
0x2AAB5E960   mov      w13, #0x0            
0x2AAB5E964   mov      w14, #0x5            
0x2AAB5E968   ldr      x12, [x19, #0x40]    
0x2AAB5E96C   str      x19, [sp, #0x98]     
0x2AAB5E970   ldr      x15, [sp, #0x70]     
0x2AAB5E974   str      x15, [x22, #0x1a0]   
0x2AAB5E978   ldr      w15, [sp, #0x84]     
0x2AAB5E97C   strb     w15, [x22, #0x1a8]   
0x2AAB5E980   ldr      x15, [sp, #0x78]     
0x2AAB5E984   str      x15, [x22, #0x1b0]   
0x2AAB5E988   ldr      x15, [sp, #0x38]     
0x2AAB5E98C   str      x15, [x22, #0x1b8]   
0x2AAB5E990   ldr      x15, [sp, #0x68]     
0x2AAB5E994   str      x15, [x22, #0x1c0]   
0x2AAB5E998   ldr      x15, [sp, #0x60]     
0x2AAB5E99C   str      x15, [x22, #0x1c8]   
0x2AAB5E9A0   ldr      x15, [sp, #0x58]     
0x2AAB5E9A4   str      x15, [x22, #0x1d0]   
0x2AAB5E9A8   ldr      x15, [sp, #0x50]     
0x2AAB5E9AC   str      x15, [x22, #0x1d8]   
0x2AAB5E9B0   ldr      x15, [sp, #0x40]     
0x2AAB5E9B4   str      x15, [x22, #0x1e0]   
0x2AAB5E9B8   ldr      w15, [sp, #0x4c]     
0x2AAB5E9BC   strb     w15, [x22, #0x1e8]   
0x2AAB5E9C0   stp      x16, x17, [x22, #0x1f0] 
0x2AAB5E9C4   str      x0, [x22, #0x200]    
0x2AAB5E9C8   str      x24, [x22, #0x208]   
0x2AAB5E9CC   str      x2, [x22, #0x210]    
0x2AAB5E9D0   str      x28, [x22, #0x218]   
0x2AAB5E9D4   strb     w20, [x22, #0x220]   
0x2AAB5E9D8   str      x8, [x22, #0x228]    
0x2AAB5E9DC   str      x9, [x22, #0x230]    
0x2AAB5E9E0   str      x10, [x22, #0x238]   
0x2AAB5E9E4   str      x11, [x22, #0x240]   
0x2AAB5E9E8   str      x12, [x22, #0x248]   
0x2AAB5E9EC   str      x14, [x22, #0x250]   
0x2AAB5E9F0   strb     w13, [x22, #0x258]   
0x2AAB5E9F4   ldr      w8, [sp, #0x80]      
0x2AAB5E9F8   strb     w8, [x22, #0x259]    
0x2AAB5E9FC   ldur     x8, [x29, #-0x88]    
0x2AAB5EA00   str      x8, [x22, #0x260]    
0x2AAB5EA04   ldr      x20, [sp, #0x18]     
0x2AAB5EA08   mov      x0, x20              
0x2AAB5EA0C   bl       0x2aab2ea54          
0x2AAB5EA10   ldp      q1, q0, [x20, #0x90] 
0x2AAB5EA14   ldp      q3, q2, [x20, #0xa0] 
0x2AAB5EA18   ldur     x0, [x29, #-0x78]    
0x2AAB5EA1C   stp      q0, q2, [x0, #0xa0]  
0x2AAB5EA20   ldp      q2, q0, [x20, #0x50] 
0x2AAB5EA24   ldp      q5, q4, [x20, #0x60] 
0x2AAB5EA28   stp      q0, q4, [x0, #0x60]  
0x2AAB5EA2C   ldp      q4, q0, [x20, #0x70] 
0x2AAB5EA30   ldp      q7, q6, [x20, #0x80] 
0x2AAB5EA34   stp      q0, q6, [x0, #0x80]  
0x2AAB5EA38   ldp      q6, q0, [x20, #0x10] 
0x2AAB5EA3C   ldp      q17, q16, [x20, #0x20] 
0x2AAB5EA40   stp      q0, q16, [x0, #0x20] 
0x2AAB5EA44   ldp      q16, q0, [x20, #0x30] 
0x2AAB5EA48   ldp      q19, q18, [x20, #0x40] 
0x2AAB5EA4C   stp      q0, q18, [x0, #0x40] 
0x2AAB5EA50   ldp      q0, q18, [x20]       
0x2AAB5EA54   ldr      q20, [x20]           
0x2AAB5EA58   stp      q0, q18, [x0]        
0x2AAB5EA5C   ldr      q0, [x20, #0xb0]     
0x2AAB5EA60   stp      q3, q0, [x22, #0xb0] 
0x2AAB5EA64   stp      q5, q4, [x22, #0x70] 
0x2AAB5EA68   stp      q7, q1, [x22, #0x90] 
0x2AAB5EA6C   stp      q17, q16, [x22, #0x30] 
0x2AAB5EA70   stp      q19, q2, [x22, #0x50] 
0x2AAB5EA74   ldr      x8, [x20, #0xc0]     
0x2AAB5EA78   str      x8, [x0, #0xc0]      
0x2AAB5EA7C   ldr      x8, [x20, #0xc0]     
0x2AAB5EA80   stur     x8, [x22, #0xd0]     
0x2AAB5EA84   stp      q20, q6, [x22, #0x10] 
0x2AAB5EA88   bl       0x2aab2d690          
0x2AAB5EA8C   mov      x24, x0              
0x2AAB5EA90   add      x0, x22, #0x10       
0x2AAB5EA94   bl       0x2aab2d6e8          
0x2AAB5EA98   mov      x20, x0              
0x2AAB5EA9C   cmp      w24, #0x1            
0x2AAB5EAA0   b.ne     0x2aab5eab4          
0x2AAB5EAA4   ldr      x28, [x20]           
0x2AAB5EAA8   mov      x19, #0x4            
0x2AAB5EAAC   movk     x19, #0x3000, lsl #48 
0x2AAB5EAB0   b        0x2aab5eb10          
0x2AAB5EAB4   adrp     x0, 162669           ; 0x2d26cb000
0x2AAB5EAB8   add      x0, x0, #0xfd8       
0x2AAB5EABC   mov      w1, #0xd8            
0x2AAB5EAC0   mov      w2, #0x7             
0x2AAB5EAC4   bl       0x2b00aac10          
0x2AAB5EAC8   orr      x28, x0, #0x8000000000000000 
0x2AAB5EACC   ldr      q0, [x20]            
0x2AAB5EAD0   str      q0, [x0, #0x10]      
0x2AAB5EAD4   ldp      q0, q1, [x20, #0x30] 
0x2AAB5EAD8   ldp      q3, q2, [x20, #0x10] 
0x2AAB5EADC   stp      q0, q1, [x0, #0x40]  
0x2AAB5EAE0   stp      q3, q2, [x0, #0x20]  
0x2AAB5EAE4   ldp      q0, q1, [x20, #0x70] 
0x2AAB5EAE8   ldp      q3, q2, [x20, #0x50] 
0x2AAB5EAEC   stp      q0, q1, [x0, #0x80]  
0x2AAB5EAF0   stp      q3, q2, [x0, #0x60]  
0x2AAB5EAF4   ldp      q1, q0, [x20, #0xa0] 
0x2AAB5EAF8   ldr      q2, [x20, #0x90]     
0x2AAB5EAFC   ldr      x8, [x20, #0xc0]     
0x2AAB69E48   b        _$s13CoreAIRuntime14InferenceValueV10takeTensorAA7NDArrayVSgyF 
0x2AAB69E4C   pacibsp                       
0x2AAB69E50   str      x28, [sp, #-0x60]!   
0x2AAB69E54   stp      x27, x26, [sp, #0x10] 
0x2AAB69E58   stp      x25, x24, [sp, #0x20] 
0x2AAB69E5C   stp      x23, x22, [sp, #0x30] 
0x2AAB69E60   stp      x20, x19, [sp, #0x40] 
0x2AAB69E64   stp      x29, x30, [sp, #0x50] 
0x2AAB69E68   add      x29, sp, #0x50       
0x2AAB69E6C   sub      sp, sp, #0x390       
0x2AAB69E70   stur     x21, [x29, #-0x48]   
0x2AAB69E74   mov      x28, x2              
0x2AAB69E78   mov      x19, x1              
0x2AAB69E7C   add      x23, sp, #0x110      
0x2AAB69E80   ldp      x9, x26, [x0]        
0x2AAB69E84   ldp      x27, x25, [x0, #0x10] 
0x2AAB69E88   ldr      x8, [x0, #0x20]      
0x2AAB69E8C   stp      x8, x9, [sp, #0x8]   
0x2AAB69E90   ldrsb    w24, [x0, #0x28]     
0x2AAB69E94   cmp      w24, #0x0            
0x2AAB69E98   cset     w22, lt              
0x2AAB69E9C   ldp      q0, q1, [x20, #0xa0] 
0x2AAB69EA0   stp      q0, q1, [x23, #0x240] 
0x2AAB69EA4   ldr      x8, [x20, #0xc0]     
0x2AAB69EA8   str      x8, [sp, #0x370]     
0x2AAB69EAC   ldp      q0, q1, [x20, #0x60] 
0x2AAB69EB0   stp      q0, q1, [x23, #0x200] 
0x2AAB69EB4   ldp      q1, q0, [x20, #0x80] 
0x2AAB69EB8   stp      q1, q0, [x23, #0x220] 
0x2AAB69EBC   ldp      q0, q1, [x20, #0x20] 
0x2AAB69EC0   stp      q0, q1, [x23, #0x1c0] 
0x2AAB69EC4   ldp      q1, q0, [x20, #0x40] 
0x2AAB69EC8   stp      q1, q0, [x23, #0x1e0] 
0x2AAB69ECC   ldp      q1, q0, [x20]        
0x2AAB69ED0   stp      q1, q0, [x23, #0x1a0] 
0x2AAB69ED4   add      x0, sp, #0x2b0       
0x2AAB69ED8   bl       0x2aab2d690          
0x2AAB69EDC   cmp      w0, #0x1             
0x2AAB69EE0   cset     w8, eq               
0x2AAB69EE4   eor      w8, w22, w8          
0x2AAB69EE8   tbz      w8, #0x0, 0x2aab69ff8 
0x2AAB69EEC   mov      x8, #-0x2000000000000000 
0x2AAB69EF0   stp      xzr, x8, [sp, #0x1e0] 
0x2AAB69EF4   add      x20, sp, #0x1e0      
0x2AAB69EF8   mov      w0, #0x2f            
0x2AAB69EFC   bl       0x2b00afd50          
0x2AAB69F00   ldp      x8, x9, [sp, #0x1e0] 
0x2AAB69F04   stp      x8, x9, [sp, #0x1e0] 
0x2AAB69F08   add      x20, sp, #0x1e0      
0x2AAB69F0C   mov      x0, x19              
0x2AAB69F10   mov      x1, x28              
0x2AAB69F14   bl       0x2b00aafe0          
0x2AAB69F18   adrp     x8, 1317             ; 0x2ab08e000
0x2AAB69F1C   add      x8, x8, #0xc20       
0x2AAB69F20   sub      x8, x8, #0x20        
0x2AAB69F24   orr      x1, x8, #0x8000000000000000 
0x2AAB69F28   add      x20, sp, #0x1e0      
0x2AAB69F2C   mov      x0, #0x1e            
0x2AAB69F30   movk     x0, #0xd000, lsl #48 
0x2AAB69F34   bl       0x2b00aafe0          
0x2AAB69F38   add      x0, sp, #0x2b0       
0x2AAB69F3C   bl       0x2aab2d690          
0x2AAB69F40   cmp      w0, #0x1             
0x2AAB69F44   cset     w8, eq               
0x2AAB69F48   strb     w8, [sp, #0x110]     
0x2AAB69F4C   adrp     x19, 162659          ; 0x2d26cc000
0x2AAB69F50   add      x19, x19, #0x2d0     ; _$s13CoreAIRuntime14InferenceValueV4KindON
0x2AAB69F54   adrp     x22, 120370          ; 0x2c819b000
0x2AAB69F58   ldr      x22, [x22, #0x418]   
0x2AAB69F5C   adrp     x23, 120370          ; 0x2c819b000
0x2AAB69F60   ldr      x23, [x23, #0x428]   
0x2AAB69F64   add      x0, sp, #0x110       
0x2AAB69F68   add      x1, sp, #0x1e0       
0x2AAB69F6C   mov      x2, x19              
0x2AAB69F70   mov      x3, x22              
0x2AAB69F74   mov      x4, x23              
0x2AAB69F78   bl       0x2b00afdd0          
0x2AAB69F7C   mov      x0, #0x202c          
0x2AAB69F80   movk     x0, #0x7865, lsl #16 
0x2AAB69F84   movk     x0, #0x6570, lsl #32 
0x2AAB69F88   movk     x0, #0x7463, lsl #48 
0x2AAB69F8C   mov      x1, #0x6465          
0x2AAB69F90   movk     x1, #0x20, lsl #16   
0x2AAB69F94   movk     x1, #0xeb00, lsl #48 
0x2AAB69F98   add      x20, sp, #0x1e0      
0x2AAB69F9C   bl       0x2b00aafe0          
0x2AAB69FA0   ubfx     w8, w24, #7, #1      
0x2AAB69FA4   strb     w8, [sp, #0x110]     
0x2AAB69FA8   add      x0, sp, #0x110       
0x2AAB69FAC   add      x1, sp, #0x1e0       
0x2AAB69FB0   mov      x2, x19              
0x2AAB69FB4   mov      x3, x22              
0x2AAB69FB8   mov      x4, x23              
0x2AAB69FBC   bl       0x2b00afdd0          
0x2AAB69FC0   ldp      x20, x22, [sp, #0x1e0] 
0x2AAB69FC4   bl       0x2aab1bd30          
0x2AAB69FC8   mov      x1, x0               
0x2AAB69FCC   adrp     x0, 162656           ; 0x2d26c9000
0x2AAB69FD0   add      x0, x0, #0xfd8       
0x2AAB69FD4   mov      x2, #0x0             
0x2AAB69FD8   mov      w3, #0x0             
0x2AAB69FDC   bl       0x2b00abc30          
0x2AAB69FE0   mov      x19, x0              
0x2AAB69FE4   strb     wzr, [x1]            
0x2AAB69FE8   stp      x20, x22, [x1, #0x8] 
0x2AAB69FEC   mov      x21, x0              
0x2AAB69FF0   bl       0x2b00abd90          
0x2AAB69FF4   b        0x2aab6a1f0          
0x2AAB69FF8   add      x0, sp, #0x2b0       
0x2AAB69FFC   bl       0x2aab2d690          
