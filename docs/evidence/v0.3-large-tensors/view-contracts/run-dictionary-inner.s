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
0x2AAB5EB00   str      x8, [x0, #0xd0]      
0x2AAB5EB04   stp      q1, q0, [x0, #0xb0]  
0x2AAB5EB08   str      q2, [x0, #0xa0]      
0x2AAB5EB0C   mov      w19, #0x4            
0x2AAB5EB10   ldr      x23, [sp, #0x30]     
0x2AAB5EB14   add      x1, x22, #0x268      
0x2AAB5EB18   ldur     x0, [x29, #-0x78]    
0x2AAB5EB1C   bl       0x2aab2d6f8          
0x2AAB5EB20   ldr      x20, [sp, #0x88]     
0x2AAB5EB24   mov      x0, x20              
0x2AAB5EB28   bl       0x2b00aace0          
0x2AAB5EB2C   mov      x26, x0              
0x2AAB5EB30   stur     x20, [x29, #-0x68]   
0x2AAB5EB34   ldur     x0, [x29, #-0x80]    
0x2AAB5EB38   ldur     x1, [x29, #-0x70]    
0x2AAB5EB3C   bl       0x2aab73b00          
0x2AAB5EB40   mov      x27, x0              
0x2AAB5EB44   mvn      w8, w1               
0x2AAB5EB48   and      x8, x8, #0x1         
0x2AAB5EB4C   ldr      x9, [x20, #0x10]     
0x2AAB5EB50   adds     x0, x9, x8           
0x2AAB5EB54   b.vs     0x2aab5ef88          
0x2AAB5EB58   mov      x24, x1              
0x2AAB5EB5C   ldr      x8, [x20, #0x18]     
0x2AAB5EB60   cmp      x8, x0               
0x2AAB5EB64   b.ge     0x2aab5eba0          
0x2AAB5EB68   sub      x20, x29, #0x68      
0x2AAB5EB6C   mov      x1, x26              
0x2AAB5EB70   bl       0x2aab5b5cc          
0x2AAB5EB74   ldp      x1, x20, [x29, #-0x70] 
0x2AAB5EB78   ldur     x0, [x29, #-0x80]    
0x2AAB5EB7C   bl       0x2aab73b00          
0x2AAB5EB80   and      w8, w1, #0x1         
0x2AAB5EB84   and      w9, w24, #0x1        
0x2AAB5EB88   cmp      w9, w8               
0x2AAB5EB8C   b.ne     0x2aab5ef34          
0x2AAB5EB90   mov      x27, x0              
0x2AAB5EB94   ldr      x26, [sp, #0x90]     
0x2AAB5EB98   tbnz     w24, #0x0, 0x2aab5e428 
0x2AAB5EB9C   b        0x2aab5ebac          
0x2AAB5EBA0   tbz      w26, #0x0, 0x2aab5ec4c 
0x2AAB5EBA4   ldr      x26, [sp, #0x90]     
0x2AAB5EBA8   tbnz     w24, #0x0, 0x2aab5e428 
0x2AAB5EBAC   ldp      x0, x20, [x29, #-0x70] 
0x2AAB5EBB0   add      x8, x20, #0x40       
0x2AAB5EBB4   lsr      x9, x27, #3          
0x2AAB5EBB8   and      x9, x9, #0x1ffffffffffffff8 
0x2AAB5EBBC   mov      w10, #0x1            
0x2AAB5EBC0   lsl      x10, x10, x27        
0x2AAB5EBC4   ldr      x11, [x8, x9]        
0x2AAB5EBC8   orr      x10, x11, x10        
0x2AAB5EBCC   str      x10, [x8, x9]        
0x2AAB5EBD0   ldr      x8, [x20, #0x30]     
0x2AAB5EBD4   add      x9, x8, x27, lsl #4  
0x2AAB5EBD8   ldur     x8, [x29, #-0x80]    
0x2AAB5EBDC   stp      x8, x0, [x9]         
0x2AAB5EBE0   ldr      x8, [x20, #0x38]     
0x2AAB5EBE4   add      x9, x8, x27, lsl #5  
0x2AAB5EBE8   stp      x28, xzr, [x9]       
0x2AAB5EBEC   stp      xzr, x19, [x9, #0x10] 
0x2AAB5EBF0   bl       0x2b00aac30          
0x2AAB5EBF4   ldur     x19, [x29, #-0x88]   
0x2AAB5EBF8   mov      x0, x19              
0x2AAB5EBFC   bl       0x2b00aad00          
0x2AAB5EC00   mov      x0, x26              
0x2AAB5EC04   bl       0x2b00aac30          
0x2AAB5EC08   ldr      x27, [sp, #0x28]     
0x2AAB5EC0C   mov      x0, x27              
0x2AAB5EC10   bl       0x2b00aac30          
0x2AAB5EC14   ldr      x0, [sp, #0x98]      
0x2AAB5EC18   bl       0x2b00aac30          
0x2AAB5EC1C   ldur     x24, [x29, #-0x90]   
0x2AAB5EC20   mov      x0, x24              
0x2AAB5EC24   bl       0x2b00aac30          
0x2AAB5EC28   ldur     x0, [x29, #-0x78]    
0x2AAB5EC2C   bl       0x2aab2d69c          
0x2AAB5EC30   ldr      x8, [x20, #0x10]     
0x2AAB5EC34   adds     x8, x8, #0x1         
0x2AAB5EC38   b.vs     0x2aab5ef98          
0x2AAB5EC3C   str      x8, [x20, #0x10]     
0x2AAB5EC40   mov      x21, x26             
0x2AAB5EC44   ldr      x26, [sp, #0x98]     
0x2AAB5EC48   b        0x2aab5e4a0          
0x2AAB5EC4C   sub      x20, x29, #0x68      
0x2AAB5EC50   bl       0x2aab5d40c          
0x2AAB5EC54   ldr      x26, [sp, #0x90]     
0x2AAB5EC58   tbz      w24, #0x0, 0x2aab5ebac 
0x2AAB5EC5C   b        0x2aab5e428          
0x2AAB5EC60   mov      x27, x20             
0x2AAB5EC64   ldr      x20, [x22, #0x350]   
0x2AAB5EC68   ldr      x0, [x22, #0x338]    
0x2AAB5EC6C   bl       0x2b00aad00          
0x2AAB5EC70   cbz      x20, 0x2aab5ec84     
0x2AAB5EC74   ldr      x0, [x22, #0x350]    
0x2AAB5EC78   ldr      x20, [x22, #0x358]   
0x2AAB5EC7C   mov      x23, x0              
0x2AAB5EC80   b        0x2aab5ec98          
0x2AAB5EC84   ldr      x20, [x22, #0x358]   
0x2AAB5EC88   ldr      x23, [x20, #0x8]     
0x2AAB5EC8C   mov      x0, x23              
0x2AAB5EC90   bl       0x2b00abd50          
0x2AAB5EC94   ldr      x0, [x22, #0x350]    
0x2AAB5EC98   str      x23, [x22, #0x388]   
0x2AAB5EC9C   ldr      x24, [x20]           
0x2AAB5ECA0   str      x24, [x22, #0x390]   
0x2AAB5ECA4   bl       0x2b00abd50          
0x2AAB5ECA8   add      x0, x24, #0x18       
0x2AAB5ECAC   bl       0x2b00abb90          
0x2AAB5ECB0   ldr      x8, [x24, #0x28]     
0x2AAB5ECB4   cbz      x8, 0x2aab5ed58      
0x2AAB5ECB8   ldr      x21, [x22, #0x370]   
0x2AAB5ECBC   ldr      x25, [x22, #0x360]   
0x2AAB5ECC0   sub      x0, x8, #0x1         
0x2AAB5ECC4   add      x20, x24, #0x20      
0x2AAB5ECC8   mov      x8, x21              
0x2AAB5ECCC   bl       0x2aab595e4          
0x2AAB5ECD0   mov      x0, x21              
0x2AAB5ECD4   mov      x1, x25              
0x2AAB5ECD8   bl       0x2aab52490          
0x2AAB5ECDC   ldr      x20, [x22, #0x378]   
0x2AAB5ECE0   ldr      x21, [x22, #0x360]   
0x2AAB5ECE4   ldr      w19, [x22, #0x3b0]   
0x2AAB5ECE8   ldr      x25, [x22, #0x348]   
0x2AAB5ECEC   ldr      x26, [x22, #0x340]   
0x2AAB5ECF0   add      x0, x24, #0x18       
0x2AAB5ECF4   bl       0x2b00abba0          
0x2AAB5ECF8   mov      x0, x21              
0x2AAB5ECFC   mov      x1, x20              
0x2AAB5ED00   bl       0x2aab52490          
0x2AAB5ED04   stur     x27, [x29, #-0x68]   
0x2AAB5ED08   mov      w8, #0x101           
0x2AAB5ED0C   movk     w8, #0x1, lsl #16    
0x2AAB5ED10   sub      x1, x29, #0x68       
0x2AAB5ED14   and      w4, w19, w8          
0x2AAB5ED18   mov      x0, #0x0             
0x2AAB5ED1C   mov      x2, x26              
0x2AAB5ED20   mov      x3, x25              
0x2AAB5ED24   mov      x5, x23              
0x2AAB5ED28   mov      x21, #0x0            
0x2AAB5ED2C   bl       0x2aab5015c          
0x2AAB5ED30   ldr      x20, [x22, #0x378]   
0x2AAB5ED34   cbz      x21, 0x2aab5ee30     
0x2AAB5ED38   mov      x25, x21             
0x2AAB5ED3C   mov      x0, x20              
0x2AAB5ED40   mov      x20, x24             
0x2AAB5ED44   bl       0x2aab5196c          
0x2AAB5ED48   bl       0x2b00abd90          
0x2AAB5ED4C   mov      x0, x23              
0x2AAB5ED50   bl       0x2b00aad00          
0x2AAB5ED54   b        0x2aab5eda8          
0x2AAB5ED58   ldr      x20, [x24, #0x10]    
0x2AAB5ED5C   ldp      x0, x1, [x24, #0x38] 
0x2AAB5ED60   ldr      x2, [x24, #0x48]     
0x2AAB5ED64   adrp     x26, 120381          ; 0x2c819b000
0x2AAB5ED68   ldr      x26, [x26, #0xfe0]   
0x2AAB5ED6C   mov      x3, x26              
0x2AAB5ED70   mov      x21, #0x0            
0x2AAB5ED74   bl       0x2aab63cd8          
0x2AAB5ED78   cbz      x21, 0x2aab5eee0     
0x2AAB5ED7C   mov      x25, x21             
0x2AAB5ED80   ldr      x20, [x22, #0x348]   
0x2AAB5ED84   ldr      x19, [x22, #0x340]   
0x2AAB5ED88   add      x0, x24, #0x18       
0x2AAB5ED8C   bl       0x2b00abba0          
0x2AAB5ED90   mov      x0, x23              
0x2AAB5ED94   bl       0x2b00aad00          
0x2AAB5ED98   ldr      x0, [x20]            
0x2AAB5ED9C   bl       0x2b00aac30          
0x2AAB5EDA0   ldr      x0, [x19]            
0x2AAB5EDA4   bl       0x2b00aac30          
0x2AAB5EDA8   ldr      x20, [x22, #0x378]   
0x2AAB5EDAC   ldr      x21, [x22, #0x370]   
0x2AAB5EDB0   ldr      x23, [x22, #0x360]   
0x2AAB5EDB4   mov      x0, x27              
0x2AAB5EDB8   bl       0x2b00aac30          
0x2AAB5EDBC   mov      x0, x20              
0x2AAB5EDC0   bl       0x2b00b2ac0          
0x2AAB5EDC4   mov      x0, x21              
0x2AAB5EDC8   bl       0x2b00b2ac0          
0x2AAB5EDCC   mov      x0, x23              
0x2AAB5EDD0   bl       0x2b00b2ac0          
0x2AAB5EDD4   mov      x0, x22              
0x2AAB5EDD8   ldr      x1, [x0, #0x8]!      
0x2AAB5EDDC   ldur     x8, [x29, #-0x58]    
0x2AAB5EDE0   adrp     x9, 120383           ; 0x2c819d000
0x2AAB5EDE4   ldr      x9, [x9, #0x820]     
0x2AAB5EDE8   ldr      x9, [x9]             
0x2AAB5EDEC   cmp      x9, x8               
0x2AAB5EDF0   b.ne     0x2aab5ef9c          
0x2AAB5EDF4   mov      x20, x25             
0x2AAB5EDF8   ldp      x29, x30, [sp, #0x130] 
0x2AAB5EDFC   ldp      x21, x19, [sp, #0x118] 
0x2AAB5EE00   ldp      x24, x23, [sp, #0x108] 
0x2AAB5EE04   ldp      x26, x25, [sp, #0xf8] 
0x2AAB5EE08   ldp      x28, x27, [sp, #0xe8] 
0x2AAB5EE0C   and      x29, x29, #0xefffffffffffffff 
0x2AAB5EE10   add      sp, sp, #0x140       
0x2AAB5EE14   autibsp                       
0x2AAB5EE18   eor      x16, x30, x30, lsl #1 
0x2AAB5EE1C   tbz      x16, #0x3e, 0x2aab5ee24 
0x2AAB5EE20   brk      #0xc471              
0x2AAB5EE24   mov      x16, x0              
0x2AAB5EE28   movk     x16, #0xd707, lsl #48 
0x2AAB5EE2C   braa     x1, x16              
0x2AAB5EE30   ldr      x8, [x22, #0x368]    
0x2AAB5EE34   mov      x19, x1              
0x2AAB5EE38   str      x1, [x22, #0x398]    
0x2AAB5EE3C   str      x0, [x22, #0x3a0]    
0x2AAB5EE40   ldrsw    x21, [x8, #0x1c]     
0x2AAB5EE44   adrp     x8, 1302             ; 0x2ab074000
0x2AAB5EE48   ldr      w0, [x8, #0xd3c]     
0x2AAB5EE4C   bl       0x2b00b2aa0          
0x2AAB5EE50   mov      x17, x22             
0x2AAB5EE54   mov      x16, x0              
0x2AAB5EE58   movk     x16, #0xbda2, lsl #48 
0x2AAB5EE5C   str      x0, [x22, #0x3a8]    
0x2AAB5EE60   pacda    x17, x16             
0x2AAB5EE64   str      x17, [x0]            
0x2AAB5EE68   add      x8, x0, #0x8         
0x2AAB5EE6C   adrp     x16, 0               ; 0x2aab5e000
0x2AAB5EE70   add      x16, x16, #0xfa0     
0x2AAB5EE74   mov      x17, x8              
0x2AAB5EE78   movk     x17, #0xd707, lsl #48 
0x2AAB5EE7C   pacia    x16, x17             
0x2AAB5EE80   str      x16, [x0, #0x8]      
0x2AAB5EE84   ldur     x8, [x29, #-0x58]    
0x2AAB5EE88   adrp     x9, 120383           ; 0x2c819d000
0x2AAB5EE8C   ldr      x9, [x9, #0x820]     
0x2AAB5EE90   ldr      x9, [x9]             
0x2AAB5EE94   cmp      x9, x8               
0x2AAB5EE98   b.ne     0x2aab5ef9c          
0x2AAB5EE9C   add      x1, x20, x21         
0x2AAB5EEA0   mov      x22, x0              
0x2AAB5EEA4   mov      x0, x19              
0x2AAB5EEA8   mov      x2, #0x0             
0x2AAB5EEAC   mov      w3, #0x1             
0x2AAB5EEB0   ldp      x29, x30, [sp, #0x130] 
0x2AAB5EEB4   ldp      x21, x19, [sp, #0x118] 
0x2AAB5EEB8   ldp      x24, x23, [sp, #0x108] 
0x2AAB5EEBC   ldp      x26, x25, [sp, #0xf8] 
0x2AAB5EEC0   ldp      x28, x27, [sp, #0xe8] 
0x2AAB5EEC4   and      x29, x29, #0xefffffffffffffff 
0x2AAB5EEC8   add      sp, sp, #0x140       
0x2AAB5EECC   autibsp                       
0x2AAB5EED0   eor      x16, x30, x30, lsl #1 
0x2AAB5EED4   tbz      x16, #0x3e, 0x2aab5eedc 
0x2AAB5EED8   brk      #0xc471              
0x2AAB5EEDC   b        0x2aab4084c          
0x2AAB5EEE0   ldr      x21, [x22, #0x370]   
0x2AAB5EEE4   ldr      x9, [x22, #0x368]    
0x2AAB5EEE8   ldr      x25, [x22, #0x360]   
0x2AAB5EEEC   adrp     x8, 150672           ; 0x2cf7ee000
0x2AAB5EEF0   ldr      x10, [x8, #0x4f0]    
0x2AAB5EEF4   add      x8, x24, x10         
0x2AAB5EEF8   stp      x0, xzr, [x21, #0x8] 
0x2AAB5EEFC   str      x20, [x21]           
0x2AAB5EF00   ldrsw    x10, [x9, #0x20]     
0x2AAB5EF04   add      x10, x21, x10        
0x2AAB5EF08   str      x26, [x10]           
0x2AAB5EF0C   ldrsw    x9, [x9, #0x1c]      
0x2AAB5EF10   add      x1, x21, x9          
0x2AAB5EF14   mov      x0, x8               
0x2AAB5EF18   bl       0x2aab5179c          
0x2AAB5EF1C   mov      x0, x21              
0x2AAB5EF20   mov      x1, x25              
0x2AAB5EF24   bl       0x2aab52490          
0x2AAB5EF28   mov      x0, x20              
0x2AAB5EF2C   bl       0x2b00abd50          
0x2AAB5EF30   b        0x2aab5ecdc          
0x2AAB5EF34   ldur     x8, [x29, #-0x58]    
0x2AAB5EF38   adrp     x9, 120383           ; 0x2c819d000
0x2AAB5EF3C   ldr      x9, [x9, #0x820]     
0x2AAB5EF40   ldr      x9, [x9]             
0x2AAB5EF44   cmp      x9, x8               
0x2AAB5EF48   b.ne     0x2aab5ef9c          
0x2AAB5EF4C   adrp     x0, 120380           ; 0x2c819a000
0x2AAB5EF50   ldr      x0, [x0, #0x658]     
0x2AAB5EF54   ldp      x29, x30, [sp, #0x130] 
0x2AAB5EF58   ldp      x21, x19, [sp, #0x118] 
0x2AAB5EF5C   ldp      x24, x23, [sp, #0x108] 
0x2AAB5EF60   ldp      x26, x25, [sp, #0xf8] 
0x2AAB5EF64   ldp      x28, x27, [sp, #0xe8] 
0x2AAB5EF68   and      x29, x29, #0xefffffffffffffff 
0x2AAB5EF6C   add      sp, sp, #0x140       
0x2AAB5EF70   autibsp                       
0x2AAB5EF74   eor      x16, x30, x30, lsl #1 
0x2AAB5EF78   tbz      x16, #0x3e, 0x2aab5ef80 
0x2AAB5EF7C   brk      #0xc471              
0x2AAB5EF80   b        0x2b00abe50          
0x2AAB5EF84   brk      #0x1                 
0x2AAB5EF88   brk      #0x1                 
0x2AAB5EF8C   brk      #0x1                 
0x2AAB5EF90   brk      #0x1                 
0x2AAB5EF94   brk      #0x1                 
0x2AAB5EF98   brk      #0x1                 
0x2AAB5EF9C   bl       0x2b00aa710          
0x2AAB5EFA0   pacibsp                       
0x2AAB5EFA4   orr      x29, x29, #0x1000000000000000 
0x2AAB5EFA8   sub      sp, sp, #0x20        
0x2AAB5EFAC   stp      x29, x30, [sp, #0x10] 
0x2AAB5EFB0   add      x16, sp, #0x8        
0x2AAB5EFB4   movk     x16, #0xc31a, lsl #48 
0x2AAB5EFB8   mov      x17, x22             
0x2AAB5EFBC   pacdb    x17, x16             
0x2AAB5EFC0   str      x17, [sp, #0x8]      
0x2AAB5EFC4   add      x29, sp, #0x10       
0x2AAB5EFC8   mov      x17, x22             
0x2AAB5EFCC   adrp     x8, 120383           ; 0x2c819d000
0x2AAB5EFD0   ldr      x8, [x8, #0x820]     
0x2AAB5EFD4   ldr      x8, [x8]             
0x2AAB5EFD8   str      x8, [sp]             
0x2AAB5EFDC   ldr      x8, [x22]            
0x2AAB5EFE0   mov      x16, x8              
0x2AAB5EFE4   movk     x17, #0xbda2, lsl #48 
0x2AAB5EFE8   autda    x16, x17             
0x2AAB5EFEC   mov      x17, x16             
0x2AAB5EFF0   xpacd    x17                  
0x2AAB5EFF4   cmp      x16, x17             
0x2AAB5EFF8   b.eq     0x2aab5f000          
0x2AAB5EFFC   brk      #0xc472              
0x2AAB5F000   sub      x9, x29, #0x8        
0x2AAB5F004   movk     x9, #0xc31a, lsl #48 
0x2AAB5F008   mov      x17, x16             
0x2AAB5F00C   mov      x16, x9              
0x2AAB5F010   pacda    x17, x16             
0x2AAB5F014   sub      x9, x29, #0x8        
0x2AAB5F018   str      x17, [x9]            
0x2AAB5F01C   mov      x16, x8              
0x2AAB5F020   mov      x17, x22             
0x2AAB5F024   movk     x17, #0xbda2, lsl #48 
0x2AAB5F028   autda    x16, x17             
0x2AAB5F02C   ldr      x0, [x16, #0x3a8]    
0x2AAB5F030   ldr      x16, [x22]           
0x2AAB5F034   mov      x17, x22             
0x2AAB5F038   movk     x17, #0xbda2, lsl #48 
0x2AAB5F03C   autda    x16, x17             
0x2AAB5F040   mov      x17, x16             
0x2AAB5F044   xpacd    x17                  
0x2AAB5F048   cmp      x16, x17             
0x2AAB5F04C   b.eq     0x2aab5f054          
0x2AAB5F050   brk      #0xc472              
0x2AAB5F054   mov      x22, x16             
0x2AAB5F058   bl       0x2b00b2ac0          
0x2AAB5F05C   adrp     x16, 0               ; 0x2aab5f000
0x2AAB5F060   add      x16, x16, #0xb0      
0x2AAB5F064   paciza   x16                  
0x2AAB5F068   ldr      x8, [sp]             
0x2AAB5F06C   adrp     x9, 120382           ; 0x2c819d000
0x2AAB5F070   ldr      x9, [x9, #0x820]     
0x2AAB5F074   ldr      x9, [x9]             
0x2AAB5F078   cmp      x9, x8               
0x2AAB5F07C   b.ne     0x2aab5f0ac          
0x2AAB5F080   mov      x0, x16              
0x2AAB5F084   mov      x1, #0x0             
0x2AAB5F088   mov      x2, #0x0             
0x2AAB5F08C   ldp      x29, x30, [sp, #0x10] 
0x2AAB5F090   and      x29, x29, #0xefffffffffffffff 
0x2AAB5F094   add      sp, sp, #0x20        
0x2AAB5F098   autibsp                       
0x2AAB5F09C   eor      x16, x30, x30, lsl #1 
0x2AAB5F0A0   tbz      x16, #0x3e, 0x2aab5f0a8 
0x2AAB5F0A4   brk      #0xc471              
0x2AAB5F0A8   b        0x2b00b2ae0          
0x2AAB5F0AC   bl       0x2b00aa710          
0x2AAB5F0B0   pacibsp                       
0x2AAB5F0B4   orr      x29, x29, #0x1000000000000000 
0x2AAB5F0B8   sub      sp, sp, #0x70        
0x2AAB5F0BC   stp      x28, x27, [sp, #0x18] 
0x2AAB5F0C0   stp      x26, x25, [sp, #0x28] 
0x2AAB5F0C4   stp      x24, x23, [sp, #0x38] 
0x2AAB5F0C8   stp      x21, x19, [sp, #0x48] 
0x2AAB5F0CC   stp      x29, x30, [sp, #0x60] 
0x2AAB5F0D0   add      x16, sp, #0x58       
0x2AAB5F0D4   movk     x16, #0xc31a, lsl #48 
0x2AAB5F0D8   mov      x17, x22             
0x2AAB5F0DC   pacdb    x17, x16             
0x2AAB5F0E0   str      x17, [sp, #0x58]     
0x2AAB5F0E4   add      x29, sp, #0x60       
0x2AAB5F0E8   adrp     x8, 120382           ; 0x2c819d000
0x2AAB5F0EC   ldr      x8, [x8, #0x820]     
0x2AAB5F0F0   ldr      x8, [x8]             
0x2AAB5F0F4   str      x8, [sp, #0x10]      
0x2AAB5F0F8   ldr      x21, [x22, #0x3a0]   
0x2AAB5F0FC   ldr      x19, [x22, #0x398]   
