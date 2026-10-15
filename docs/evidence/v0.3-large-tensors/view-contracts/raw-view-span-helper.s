0x2AAB8E260   pacibsp                       
0x2AAB8E264   stp      x28, x27, [sp, #-0x60]! 
0x2AAB8E268   stp      x26, x25, [sp, #0x10] 
0x2AAB8E26C   stp      x24, x23, [sp, #0x20] 
0x2AAB8E270   stp      x22, x21, [sp, #0x30] 
0x2AAB8E274   stp      x20, x19, [sp, #0x40] 
0x2AAB8E278   stp      x29, x30, [sp, #0x50] 
0x2AAB8E27C   add      x29, sp, #0x50       
0x2AAB8E280   sub      sp, sp, #0x1e0       
0x2AAB8E284   add      x21, sp, #0xd8       
0x2AAB8E288   ldr      x23, [x20]           
0x2AAB8E28C   ldrb     w24, [x20, #0x8]     
0x2AAB8E290   ldur     w8, [x20, #0x9]      
0x2AAB8E294   stur     w8, [x21, #0x41]     
0x2AAB8E298   ldr      w8, [x20, #0xc]      
0x2AAB8E29C   str      w8, [x21, #0x44]     
0x2AAB8E2A0   ldp      x22, x11, [x20, #0x10] 
0x2AAB8E2A4   ldp      q0, q1, [x20, #0x20] 
0x2AAB8E2A8   stur     q0, [x21, #0x58]     
0x2AAB8E2AC   stur     q1, [x21, #0x68]     
0x2AAB8E2B0   ldr      x1, [x20, #0x40]     
0x2AAB8E2B4   ldrb     w15, [x20, #0x48]    
0x2AAB8E2B8   ldr      w8, [x20, #0x4c]     
0x2AAB8E2BC   str      w8, [x21, #0x84]     
0x2AAB8E2C0   ldur     w8, [x20, #0x49]     
0x2AAB8E2C4   stur     w8, [x21, #0x81]     
0x2AAB8E2C8   ldur     q0, [x20, #0x58]     
0x2AAB8E2CC   ldur     q1, [x20, #0x68]     
0x2AAB8E2D0   stp      q0, q1, [x21, #0x90] 
0x2AAB8E2D4   ldur     w8, [x20, #0x81]     
0x2AAB8E2D8   stur     w8, [x21, #0xb9]     
0x2AAB8E2DC   ldr      w8, [x20, #0x84]     
0x2AAB8E2E0   str      w8, [x21, #0xbc]     
0x2AAB8E2E4   ldp      q0, q1, [x20, #0x90] 
0x2AAB8E2E8   stur     q0, [x21, #0xc8]     
0x2AAB8E2EC   stur     q1, [x21, #0xd8]     
0x2AAB8E2F0   ldr      x8, [x20, #0xc0]     
0x2AAB8E2F4   str      x8, [x21, #0xf8]     
0x2AAB8E2F8   ldur     x8, [x20, #0xba]     
0x2AAB8E2FC   stur     x8, [x21, #0xf2]     
0x2AAB8E300   ldr      x13, [x20, #0x50]    
0x2AAB8E304   ldr      x3, [x20, #0x78]     
0x2AAB8E308   str      x23, [x21, #0x38]    
0x2AAB8E30C   ldrb     w14, [x20, #0x80]    
0x2AAB8E310   strb     w24, [sp, #0x118]    
0x2AAB8E314   add      x10, sp, #0x110      
0x2AAB8E318   ldr      x9, [x20, #0x88]     
0x2AAB8E31C   ldr      x8, [x20, #0xb0]     
0x2AAB8E320   ldrb     w12, [x20, #0xb8]    
0x2AAB8E324   stp      x22, x11, [x21, #0x48] 
0x2AAB8E328   ldrb     w19, [x20, #0xb9]    
0x2AAB8E32C   str      x1, [x21, #0x78]     
0x2AAB8E330   strb     w15, [sp, #0x158]    
0x2AAB8E334   str      x13, [x21, #0x88]    
0x2AAB8E338   str      x3, [x21, #0xb0]     
0x2AAB8E33C   strb     w14, [sp, #0x190]    
0x2AAB8E340   str      x9, [x21, #0xc0]     
0x2AAB8E344   str      x8, [x21, #0xe8]     
0x2AAB8E348   strb     w12, [sp, #0x1c8]    
0x2AAB8E34C   strb     w19, [sp, #0x1c9]    
0x2AAB8E350   cmp      w15, #0x1            
0x2AAB8E354   b.ne     0x2aab8e390          
0x2AAB8E358   add      x0, x11, #0x20       
0x2AAB8E35C   tst      x0, #0x7             
0x2AAB8E360   b.ne     0x2aab8e548          
0x2AAB8E364   ldr      x1, [x11, #0x10]     
0x2AAB8E368   cmp      w14, #0x1            
0x2AAB8E36C   b.eq     0x2aab8e39c          
0x2AAB8E370   add      x2, x10, #0x50       
0x2AAB8E374   cmp      w12, #0x1            
0x2AAB8E378   b.ne     0x2aab8e3b4          
0x2AAB8E37C   add      x4, x9, #0x20        
0x2AAB8E380   tst      x4, #0x7             
0x2AAB8E384   b.ne     0x2aab8e550          
0x2AAB8E388   ldr      x8, [x9, #0x10]      
0x2AAB8E38C   b        0x2aab8e3b8          
0x2AAB8E390   add      x0, x10, #0x18       
0x2AAB8E394   cmp      w14, #0x1            
0x2AAB8E398   b.ne     0x2aab8e370          
0x2AAB8E39C   add      x2, x13, #0x20       
0x2AAB8E3A0   tst      x2, #0x7             
0x2AAB8E3A4   b.ne     0x2aab8e54c          
0x2AAB8E3A8   ldr      x3, [x13, #0x10]     
0x2AAB8E3AC   cmp      w12, #0x1            
0x2AAB8E3B0   b.eq     0x2aab8e37c          
0x2AAB8E3B4   add      x4, x10, #0x88       
0x2AAB8E3B8   cmp      x1, x8               
0x2AAB8E3BC   b.ne     0x2aab8e55c          
0x2AAB8E3C0   cbz      x1, 0x2aab8e434      
0x2AAB8E3C4   str      w24, [sp, #0x4c]     
0x2AAB8E3C8   stp      x23, x22, [sp, #0x50] 
0x2AAB8E3CC   add      x8, sp, #0x68        
0x2AAB8E3D0   mov      x5, x1               
0x2AAB8E3D4   bl       0x2aab53954          
0x2AAB8E3D8   ldp      x11, x22, [sp, #0x68] 
0x2AAB8E3DC   ldp      x28, x8, [sp, #0x78] 
0x2AAB8E3E0   ldp      x9, x10, [sp, #0x88] 
0x2AAB8E3E4   ldrb     w26, [sp, #0x98]     
0x2AAB8E3E8   ldp      x27, x25, [sp, #0xa0] 
0x2AAB8E3EC   ldp      x20, x12, [sp, #0xb0] 
0x2AAB8E3F0   ldp      x13, x23, [sp, #0xc0] 
0x2AAB8E3F4   ldrb     w24, [sp, #0xd0]     
0x2AAB8E3F8   stp      x11, x22, [sp, #0x68] 
0x2AAB8E3FC   stp      x28, x8, [sp, #0x78] 
0x2AAB8E400   stp      x9, x10, [sp, #0x88] 
0x2AAB8E404   strb     w26, [sp, #0x98]     
0x2AAB8E408   stp      x27, x25, [sp, #0xd8] 
0x2AAB8E40C   stp      x20, x12, [x21, #0x10] 
0x2AAB8E410   stp      x13, x23, [x21, #0x20] 
0x2AAB8E414   strb     w24, [sp, #0x108]    
0x2AAB8E418   cmp      w26, #0x1            
0x2AAB8E41C   b.ne     0x2aab8e44c          
0x2AAB8E420   add      x0, x11, #0x20       
0x2AAB8E424   tst      x0, #0x7             
0x2AAB8E428   b.ne     0x2aab8e554          
0x2AAB8E42C   ldr      x1, [x11, #0x10]     
0x2AAB8E430   b        0x2aab8e454          
0x2AAB8E434   strb     w19, [sp, #0x68]     
0x2AAB8E438   add      x4, sp, #0x68        
0x2AAB8E43C   bl       0x2aab53d4c          
0x2AAB8E440   mov      x21, x0              
0x2AAB8E444   mov      x19, x1              
0x2AAB8E448   b        0x2aab8e4d4          
0x2AAB8E44C   add      x0, sp, #0x68        
0x2AAB8E450   mov      x1, x10              
0x2AAB8E454   cmp      w24, #0x1            
0x2AAB8E458   stp      x9, x8, [sp, #0x38]  
0x2AAB8E45C   stp      x11, x10, [sp, #0x28] 
0x2AAB8E460   stp      x13, x12, [sp, #0x18] 
0x2AAB8E464   b.ne     0x2aab8e47c          
0x2AAB8E468   add      x2, x27, #0x20       
0x2AAB8E46C   tst      x2, #0x7             
0x2AAB8E470   b.ne     0x2aab8e558          
0x2AAB8E474   ldr      x3, [x27, #0x10]     
0x2AAB8E478   b        0x2aab8e484          
0x2AAB8E47C   add      x2, sp, #0xd8        
0x2AAB8E480   mov      x3, x23              
0x2AAB8E484   strb     w19, [sp, #0x67]     
0x2AAB8E488   add      x4, sp, #0x67        
0x2AAB8E48C   bl       0x2aab53d4c          
0x2AAB8E490   mov      x21, x0              
0x2AAB8E494   mov      x19, x1              
0x2AAB8E498   mov      x0, x27              
0x2AAB8E49C   mov      x1, x25              
0x2AAB8E4A0   mov      x2, x20              
0x2AAB8E4A4   ldp      x4, x3, [sp, #0x18]  
0x2AAB8E4A8   mov      x5, x23              
0x2AAB8E4AC   mov      x6, x24              
0x2AAB8E4B0   bl       0x2aab2e9ec          
0x2AAB8E4B4   ldp      x0, x5, [sp, #0x28]  
0x2AAB8E4B8   mov      x1, x22              
0x2AAB8E4BC   mov      x2, x28              
0x2AAB8E4C0   ldp      x4, x3, [sp, #0x38]  
0x2AAB8E4C4   mov      x6, x26              
0x2AAB8E4C8   bl       0x2aab2e9ec          
0x2AAB8E4CC   ldp      x23, x22, [sp, #0x50] 
0x2AAB8E4D0   ldr      w24, [sp, #0x4c]     
0x2AAB8E4D4   cbnz     x21, 0x2aab8e590     
0x2AAB8E4D8   cbz      w24, 0x2aab8e520     
0x2AAB8E4DC   cmp      w24, #0x1            
0x2AAB8E4E0   b.ne     0x2aab8e504          
0x2AAB8E4E4   mov      x0, x23              
0x2AAB8E4E8   bl       0x2b00aad20          
0x2AAB8E4EC   bl       0x2b0003dd0          
0x2AAB8E4F0   mov      x20, x0              
0x2AAB8E4F4   mov      x0, x23              
0x2AAB8E4F8   bl       0x2b00aa920          
0x2AAB8E4FC   mov      x23, x20             
0x2AAB8E500   b        0x2aab8e520          
0x2AAB8E504   mov      x0, x23              
0x2AAB8E508   bl       0x2b00aaaa0          
0x2AAB8E50C   mov      x20, x0              
0x2AAB8E510   bl       0x2b00b4f40          
0x2AAB8E514   mov      x23, x0              
0x2AAB8E518   mov      x0, x20              
0x2AAB8E51C   bl       0x2b00aaa90          
0x2AAB8E520   add      x0, x23, x22         
0x2AAB8E524   add      x1, x0, x19          
0x2AAB8E528   add      sp, sp, #0x1e0       
0x2AAB8E52C   ldp      x29, x30, [sp, #0x50] 
0x2AAB8E530   ldp      x20, x19, [sp, #0x40] 
0x2AAB8E534   ldp      x22, x21, [sp, #0x30] 
0x2AAB8E538   ldp      x24, x23, [sp, #0x20] 
0x2AAB8E53C   ldp      x26, x25, [sp, #0x10] 
0x2AAB8E540   ldp      x28, x27, [sp], #0x60 
0x2AAB8E544   retab                         
0x2AAB8E548   brk      #0x1                 
0x2AAB8E54C   brk      #0x1                 
0x2AAB8E550   brk      #0x1                 
0x2AAB8E554   brk      #0x1                 
0x2AAB8E558   brk      #0x1                 
0x2AAB8E55C   str      wzr, [sp, #0x8]      
0x2AAB8E560   mov      w8, #0x190           
0x2AAB8E564   str      x8, [sp]             
0x2AAB8E568   adrp     x0, 1283             ; 0x2ab091000
0x2AAB8E56C   add      x0, x0, #0x120       
0x2AAB8E570   adrp     x5, 1280             ; 0x2ab08e000
0x2AAB8E574   add      x5, x5, #0x5e0       
0x2AAB8E578   mov      w1, #0xb             
0x2AAB8E57C   mov      w2, #0x2             
0x2AAB8E580   mov      x3, #0x0             
0x2AAB8E584   mov      x4, #-0x2000000000000000 
0x2AAB8E588   mov      w6, #0x1c            
0x2AAB8E58C   b        0x2aab8e5d0          
0x2AAB8E590   adrp     x8, 1281             ; 0x2ab08f000
0x2AAB8E594   add      x8, x8, #0x9b0       
0x2AAB8E598   sub      x8, x8, #0x20        
0x2AAB8E59C   str      wzr, [sp, #0x8]      
0x2AAB8E5A0   mov      w9, #0x6f            
0x2AAB8E5A4   str      x9, [sp]             
0x2AAB8E5A8   adrp     x0, 1283             ; 0x2ab091000
0x2AAB8E5AC   add      x0, x0, #0x120       
0x2AAB8E5B0   adrp     x5, 1281             ; 0x2ab08f000
0x2AAB8E5B4   add      x5, x5, #0x930       
0x2AAB8E5B8   orr      x4, x8, #0x8000000000000000 
0x2AAB8E5BC   mov      w1, #0xb             
0x2AAB8E5C0   mov      w2, #0x2             
0x2AAB8E5C4   mov      x3, #0x4a            
0x2AAB8E5C8   movk     x3, #0xd000, lsl #48 
0x2AAB8E5CC   mov      w6, #0x23            
0x2AAB8E5D0   mov      w7, #0x2             
0x2AAB8E5D4   bl       0x2b00ab0d0          
0x2AAB8E5D8   brk      #0x1                 
