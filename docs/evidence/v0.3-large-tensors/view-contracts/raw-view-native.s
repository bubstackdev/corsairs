0x2AAB8C0F4   pacibsp                       
0x2AAB8C0F8   stp      x22, x21, [sp, #-0x30]! 
0x2AAB8C0FC   stp      x20, x19, [sp, #0x10] 
0x2AAB8C100   stp      x29, x30, [sp, #0x20] 
0x2AAB8C104   add      x29, sp, #0x20       
0x2AAB8C108   ldr      x19, [x20]           
0x2AAB8C10C   ldrb     w8, [x20, #0x8]      
0x2AAB8C110   ldr      x21, [x20, #0x10]    
0x2AAB8C114   cbz      w8, 0x2aab8c15c      
0x2AAB8C118   cmp      w8, #0x1             
0x2AAB8C11C   b.ne     0x2aab8c140          
0x2AAB8C120   mov      x0, x19              
0x2AAB8C124   bl       0x2b00aad20          
0x2AAB8C128   bl       0x2b0003dd0          
0x2AAB8C12C   mov      x20, x0              
0x2AAB8C130   mov      x0, x19              
0x2AAB8C134   bl       0x2b00aa920          
0x2AAB8C138   mov      x19, x20             
0x2AAB8C13C   b        0x2aab8c15c          
0x2AAB8C140   mov      x0, x19              
0x2AAB8C144   bl       0x2b00aaaa0          
0x2AAB8C148   mov      x20, x0              
0x2AAB8C14C   bl       0x2b00b4f40          
0x2AAB8C150   mov      x19, x0              
0x2AAB8C154   mov      x0, x20              
0x2AAB8C158   bl       0x2b00aaa90          
0x2AAB8C15C   add      x0, x19, x21         
0x2AAB8C160   ldp      x29, x30, [sp, #0x20] 
0x2AAB8C164   ldp      x20, x19, [sp, #0x10] 
0x2AAB8C168   ldp      x22, x21, [sp], #0x30 
0x2AAB8C16C   retab                         
0x2AAB8C170   pacibsp                       
0x2AAB8C174   stp      x28, x27, [sp, #-0x60]! 
0x2AAB8C178   stp      x26, x25, [sp, #0x10] 
0x2AAB8C17C   stp      x24, x23, [sp, #0x20] 
0x2AAB8C180   stp      x22, x21, [sp, #0x30] 
0x2AAB8C184   stp      x20, x19, [sp, #0x40] 
0x2AAB8C188   stp      x29, x30, [sp, #0x50] 
0x2AAB8C18C   add      x29, sp, #0x50       
0x2AAB8C190   sub      sp, sp, #0x1d0       
0x2AAB8C194   add      x21, sp, #0xb8       
0x2AAB8C198   ldr      q0, [x20]            
0x2AAB8C19C   stur     q0, [x21, #0x38]     
0x2AAB8C1A0   ldp      x13, x12, [x20, #0x10] 
0x2AAB8C1A4   ldp      q0, q1, [x20, #0x20] 
0x2AAB8C1A8   stur     q0, [x21, #0x58]     
0x2AAB8C1AC   stur     q1, [x21, #0x68]     
0x2AAB8C1B0   ldr      x1, [x20, #0x40]     
0x2AAB8C1B4   ldrb     w15, [x20, #0x48]    
0x2AAB8C1B8   ldur     w8, [x20, #0x49]     
0x2AAB8C1BC   stur     w8, [x21, #0x81]     
0x2AAB8C1C0   ldr      w8, [x20, #0x4c]     
0x2AAB8C1C4   str      w8, [x21, #0x84]     
0x2AAB8C1C8   ldr      x9, [x20, #0x50]     
0x2AAB8C1CC   ldur     q0, [x20, #0x58]     
0x2AAB8C1D0   ldur     q1, [x20, #0x68]     
0x2AAB8C1D4   stp      q0, q1, [x21, #0x90] 
0x2AAB8C1D8   ldr      x3, [x20, #0x78]     
0x2AAB8C1DC   ldur     w8, [x20, #0x81]     
0x2AAB8C1E0   stur     w8, [x21, #0xb9]     
0x2AAB8C1E4   ldr      w8, [x20, #0x84]     
0x2AAB8C1E8   str      w8, [x21, #0xbc]     
0x2AAB8C1EC   ldp      q0, q1, [x20, #0x90] 
0x2AAB8C1F0   stur     q0, [x21, #0xc8]     
0x2AAB8C1F4   stur     q1, [x21, #0xd8]     
0x2AAB8C1F8   ldr      x8, [x20, #0xc0]     
0x2AAB8C1FC   str      x8, [x21, #0xf8]     
0x2AAB8C200   ldur     x8, [x20, #0xba]     
0x2AAB8C204   stur     x8, [x21, #0xf2]     
0x2AAB8C208   add      x11, sp, #0xf0       
0x2AAB8C20C   ldrb     w14, [x20, #0x80]    
0x2AAB8C210   ldr      x10, [x20, #0x88]    
0x2AAB8C214   ldr      x8, [x20, #0xb0]     
0x2AAB8C218   stp      x13, x12, [x21, #0x48] 
0x2AAB8C21C   ldrb     w13, [x20, #0xb8]    
0x2AAB8C220   str      x1, [x21, #0x78]     
0x2AAB8C224   ldrb     w20, [x20, #0xb9]    
0x2AAB8C228   strb     w15, [sp, #0x138]    
0x2AAB8C22C   str      x9, [x21, #0x88]     
0x2AAB8C230   str      x3, [x21, #0xb0]     
0x2AAB8C234   strb     w14, [sp, #0x170]    
0x2AAB8C238   str      x10, [x21, #0xc0]    
0x2AAB8C23C   str      x8, [x21, #0xe8]     
0x2AAB8C240   strb     w13, [sp, #0x1a8]    
0x2AAB8C244   strb     w20, [sp, #0x1a9]    
0x2AAB8C248   cmp      w15, #0x1            
0x2AAB8C24C   b.ne     0x2aab8c288          
0x2AAB8C250   add      x0, x12, #0x20       
0x2AAB8C254   tst      x0, #0x7             
0x2AAB8C258   b.ne     0x2aab8c3e8          
0x2AAB8C25C   ldr      x1, [x12, #0x10]     
0x2AAB8C260   cmp      w14, #0x1            
0x2AAB8C264   b.eq     0x2aab8c294          
0x2AAB8C268   add      x2, x11, #0x50       
0x2AAB8C26C   cmp      w13, #0x1            
0x2AAB8C270   b.ne     0x2aab8c2ac          
0x2AAB8C274   add      x4, x10, #0x20       
0x2AAB8C278   tst      x4, #0x7             
0x2AAB8C27C   b.ne     0x2aab8c3f0          
0x2AAB8C280   ldr      x8, [x10, #0x10]     
0x2AAB8C284   b        0x2aab8c2b0          
0x2AAB8C288   add      x0, x11, #0x18       
0x2AAB8C28C   cmp      w14, #0x1            
0x2AAB8C290   b.ne     0x2aab8c268          
0x2AAB8C294   add      x2, x9, #0x20        
0x2AAB8C298   tst      x2, #0x7             
0x2AAB8C29C   b.ne     0x2aab8c3ec          
0x2AAB8C2A0   ldr      x3, [x9, #0x10]      
0x2AAB8C2A4   cmp      w13, #0x1            
0x2AAB8C2A8   b.eq     0x2aab8c274          
0x2AAB8C2AC   add      x4, x11, #0x88       
0x2AAB8C2B0   cmp      x1, x8               
0x2AAB8C2B4   b.ne     0x2aab8c3fc          
0x2AAB8C2B8   cbz      x1, 0x2aab8c324      
0x2AAB8C2BC   add      x8, sp, #0x48        
0x2AAB8C2C0   mov      x5, x1               
0x2AAB8C2C4   bl       0x2aab53954          
0x2AAB8C2C8   ldp      x11, x27, [sp, #0x48] 
0x2AAB8C2CC   ldp      x28, x8, [sp, #0x58] 
0x2AAB8C2D0   ldp      x9, x10, [sp, #0x68] 
0x2AAB8C2D4   ldrb     w25, [sp, #0x78]     
0x2AAB8C2D8   ldp      x26, x24, [sp, #0x80] 
0x2AAB8C2DC   ldp      x19, x12, [sp, #0x90] 
0x2AAB8C2E0   ldp      x13, x22, [sp, #0xa0] 
0x2AAB8C2E4   ldrb     w23, [sp, #0xb0]     
0x2AAB8C2E8   stp      x11, x27, [sp, #0x48] 
0x2AAB8C2EC   stp      x28, x8, [sp, #0x58] 
0x2AAB8C2F0   stp      x9, x10, [sp, #0x68] 
0x2AAB8C2F4   strb     w25, [sp, #0x78]     
0x2AAB8C2F8   stp      x26, x24, [sp, #0xb8] 
0x2AAB8C2FC   stp      x19, x12, [x21, #0x10] 
0x2AAB8C300   stp      x13, x22, [x21, #0x20] 
0x2AAB8C304   strb     w23, [sp, #0xe8]     
0x2AAB8C308   cmp      w25, #0x1            
0x2AAB8C30C   b.ne     0x2aab8c33c          
0x2AAB8C310   add      x0, x11, #0x20       
0x2AAB8C314   tst      x0, #0x7             
0x2AAB8C318   b.ne     0x2aab8c3f4          
0x2AAB8C31C   ldr      x1, [x11, #0x10]     
0x2AAB8C320   b        0x2aab8c344          
0x2AAB8C324   strb     w20, [sp, #0x48]     
0x2AAB8C328   add      x4, sp, #0x48        
0x2AAB8C32C   bl       0x2aab53d4c          
0x2AAB8C330   mov      x20, x0              
0x2AAB8C334   mov      x21, x1              
0x2AAB8C338   b        0x2aab8c3bc          
0x2AAB8C33C   add      x0, sp, #0x48        
0x2AAB8C340   mov      x1, x10              
0x2AAB8C344   cmp      w23, #0x1            
0x2AAB8C348   stp      x9, x8, [sp, #0x30]  
0x2AAB8C34C   stp      x11, x10, [sp, #0x20] 
0x2AAB8C350   stp      x13, x12, [sp, #0x10] 
0x2AAB8C354   b.ne     0x2aab8c36c          
0x2AAB8C358   add      x2, x26, #0x20       
0x2AAB8C35C   tst      x2, #0x7             
0x2AAB8C360   b.ne     0x2aab8c3f8          
0x2AAB8C364   ldr      x3, [x26, #0x10]     
0x2AAB8C368   b        0x2aab8c374          
0x2AAB8C36C   add      x2, sp, #0xb8        
0x2AAB8C370   mov      x3, x22              
0x2AAB8C374   strb     w20, [sp, #0x47]     
0x2AAB8C378   add      x4, sp, #0x47        
0x2AAB8C37C   bl       0x2aab53d4c          
0x2AAB8C380   mov      x20, x0              
0x2AAB8C384   mov      x21, x1              
0x2AAB8C388   mov      x0, x26              
0x2AAB8C38C   mov      x1, x24              
0x2AAB8C390   mov      x2, x19              
0x2AAB8C394   ldp      x4, x3, [sp, #0x10]  
0x2AAB8C398   mov      x5, x22              
0x2AAB8C39C   mov      x6, x23              
0x2AAB8C3A0   bl       0x2aab2e9ec          
0x2AAB8C3A4   ldp      x0, x5, [sp, #0x20]  
0x2AAB8C3A8   mov      x1, x27              
0x2AAB8C3AC   mov      x2, x28              
0x2AAB8C3B0   ldp      x4, x3, [sp, #0x30]  
0x2AAB8C3B4   mov      x6, x25              
0x2AAB8C3B8   bl       0x2aab2e9ec          
0x2AAB8C3BC   subs     x0, x21, x20         
0x2AAB8C3C0   b.vs     0x2aab8c3e4          
0x2AAB8C3C4   add      sp, sp, #0x1d0       
0x2AAB8C3C8   ldp      x29, x30, [sp, #0x50] 
0x2AAB8C3CC   ldp      x20, x19, [sp, #0x40] 
0x2AAB8C3D0   ldp      x22, x21, [sp, #0x30] 
0x2AAB8C3D4   ldp      x24, x23, [sp, #0x20] 
0x2AAB8C3D8   ldp      x26, x25, [sp, #0x10] 
0x2AAB8C3DC   ldp      x28, x27, [sp], #0x60 
0x2AAB8C3E0   retab                         
0x2AAB8C3E4   brk      #0x1                 
0x2AAB8C3E8   brk      #0x1                 
0x2AAB8C3EC   brk      #0x1                 
0x2AAB8C3F0   brk      #0x1                 
0x2AAB8C3F4   brk      #0x1                 
0x2AAB8C3F8   brk      #0x1                 
0x2AAB8C3FC   str      wzr, [sp, #0x8]      
0x2AAB8C400   mov      w8, #0x190           
0x2AAB8C404   str      x8, [sp]             
0x2AAB8C408   adrp     x0, 1285             ; 0x2ab091000
0x2AAB8C40C   add      x0, x0, #0x120       
0x2AAB8C410   adrp     x5, 1282             ; 0x2ab08e000
0x2AAB8C414   add      x5, x5, #0x5e0       
0x2AAB8C418   mov      w1, #0xb             
0x2AAB8C41C   mov      w2, #0x2             
0x2AAB8C420   mov      x3, #0x0             
0x2AAB8C424   mov      x4, #-0x2000000000000000 
0x2AAB8C428   mov      w6, #0x1c            
0x2AAB8C42C   mov      w7, #0x2             
0x2AAB8C430   bl       0x2b00ab0d0          
0x2AAB8C434   brk      #0x1                 
0x2AAB8E134   pacibsp                       
0x2AAB8E138   stp      x29, x30, [sp, #-0x10]! 
0x2AAB8E13C   mov      x29, sp              
0x2AAB8E140   bl       0x2aab8e260          
0x2AAB8E144   sub      x8, x1, x0           
0x2AAB8E148   cmp      x0, #0x0             
0x2AAB8E14C   csel     x1, xzr, x8, eq      
0x2AAB8E150   ldp      x29, x30, [sp], #0x10 
0x2AAB8E154   retab                         
0x2AAB8E9BC   pacibsp                       
0x2AAB8E9C0   str      x28, [sp, #-0x60]!   
0x2AAB8E9C4   stp      x27, x26, [sp, #0x10] 
0x2AAB8E9C8   stp      x25, x24, [sp, #0x20] 
0x2AAB8E9CC   stp      x23, x22, [sp, #0x30] 
0x2AAB8E9D0   stp      x20, x19, [sp, #0x40] 
0x2AAB8E9D4   stp      x29, x30, [sp, #0x50] 
0x2AAB8E9D8   add      x29, sp, #0x50       
0x2AAB8E9DC   sub      sp, sp, #0xe0        
0x2AAB8E9E0   mov      x23, x5              
0x2AAB8E9E4   mov      x22, x3              
0x2AAB8E9E8   mov      x14, x1              
0x2AAB8E9EC   mov      x28, x0              
0x2AAB8E9F0   sub      x15, x29, #0x120     
0x2AAB8E9F4   mov      x10, x3              
0x2AAB8E9F8   ldr      x9, [x10, #-0x8]!    
0x2AAB8E9FC   mov      x16, x9              
0x2AAB8EA00   mov      x17, x10             
0x2AAB8EA04   movk     x17, #0x2e3f, lsl #48 
0x2AAB8EA08   autda    x16, x17             
0x2AAB8EA0C   mov      x17, x16             
0x2AAB8EA10   xpacd    x17                  
0x2AAB8EA14   cmp      x16, x17             
0x2AAB8EA18   b.eq     0x2aab8ea20          
0x2AAB8EA1C   brk      #0xc472              
0x2AAB8EA20   mov      x25, x16             
0x2AAB8EA24   mov      x16, x9              
0x2AAB8EA28   mov      x17, x10             
0x2AAB8EA2C   movk     x17, #0x2e3f, lsl #48 
0x2AAB8EA30   autda    x16, x17             
0x2AAB8EA34   ldr      x12, [x16, #0x40]    
0x2AAB8EA38   mov      x9, x12              
0x2AAB8EA3C   adrp     x17, 153911          ; 0x2d04c5000
0x2AAB8EA40   add      x17, x17, #0xf48     
0x2AAB8EA44   ldr      x16, [x17]           
0x2AAB8EA48   blraa    x16, x17             
0x2AAB8EA4C   mov      x9, sp               
0x2AAB8EA50   add      x10, x12, #0xf       
0x2AAB8EA54   and      x10, x10, #0xfffffffffffffff0 
0x2AAB8EA58   sub      x19, x9, x10         
0x2AAB8EA5C   mov      sp, x19              
0x2AAB8EA60   ldr      x26, [x20]           
0x2AAB8EA64   ldrb     w9, [x20, #0x8]      
0x2AAB8EA68   ldur     w10, [x20, #0x9]     
0x2AAB8EA6C   sub      x11, x29, #0x17      
0x2AAB8EA70   stur     w10, [x11, #-0x100]  
0x2AAB8EA74   ldr      w10, [x20, #0xc]     
0x2AAB8EA78   sub      x11, x29, #0x14      
0x2AAB8EA7C   stur     w10, [x11, #-0x100]  
0x2AAB8EA80   ldr      x10, [x20, #0x10]    
0x2AAB8EA84   ldur     q0, [x20, #0x88]     
0x2AAB8EA88   stur     q0, [x15, #0x88]     
0x2AAB8EA8C   ldur     q0, [x20, #0x98]     
0x2AAB8EA90   stur     q0, [x15, #0x98]     
0x2AAB8EA94   ldur     q0, [x20, #0xa8]     
0x2AAB8EA98   stur     q0, [x15, #0xa8]     
0x2AAB8EA9C   ldur     q0, [x20, #0xb8]     
0x2AAB8EAA0   stur     q0, [x15, #0xb8]     
0x2AAB8EAA4   ldur     q0, [x20, #0x48]     
0x2AAB8EAA8   stur     q0, [x29, #-0xd8]    
0x2AAB8EAAC   ldur     q0, [x20, #0x58]     
0x2AAB8EAB0   stur     q0, [x29, #-0xc8]    
0x2AAB8EAB4   ldur     q0, [x20, #0x68]     
0x2AAB8EAB8   stur     q0, [x29, #-0xb8]    
0x2AAB8EABC   ldur     q0, [x20, #0x78]     
0x2AAB8EAC0   stur     q0, [x29, #-0xa8]    
0x2AAB8EAC4   ldur     q0, [x20, #0x18]     
0x2AAB8EAC8   sub      x11, x29, #0x8       
0x2AAB8EACC   stur     q0, [x11, #-0x100]   
0x2AAB8EAD0   ldur     q0, [x20, #0x28]     
0x2AAB8EAD4   stur     q0, [x29, #-0xf8]    
0x2AAB8EAD8   ldur     q0, [x20, #0x38]     
0x2AAB8EADC   stur     q0, [x29, #-0xe8]    
0x2AAB8EAE0   sub      x11, x29, #0x20      
0x2AAB8EAE4   stur     x26, [x11, #-0x100]  
0x2AAB8EAE8   sub      x11, x29, #0x18      
0x2AAB8EAEC   sturb    w9, [x11, #-0x100]   
0x2AAB8EAF0   sub      x11, x29, #0x10      
0x2AAB8EAF4   stur     x10, [x11, #-0x100]  
0x2AAB8EAF8   cbz      w9, 0x2aab8eb84      
0x2AAB8EAFC   sub      x11, x29, #0x28      
0x2AAB8EB00   stur     x10, [x11, #-0x100]  
0x2AAB8EB04   stur     x19, [x29, #-0x48]   
0x2AAB8EB08   mov      x19, x14             
0x2AAB8EB0C   mov      x24, x22             
0x2AAB8EB10   mov      x22, x23             
0x2AAB8EB14   mov      x23, x8              
0x2AAB8EB18   mov      x27, x21             
0x2AAB8EB1C   cmp      w9, #0x1             
0x2AAB8EB20   b.ne     0x2aab8eb44          
0x2AAB8EB24   mov      x0, x26              
0x2AAB8EB28   bl       0x2b00aad20          
0x2AAB8EB2C   bl       0x2b0003dd0          
0x2AAB8EB30   mov      x21, x0              
0x2AAB8EB34   mov      x0, x26              
0x2AAB8EB38   bl       0x2b00aa920          
0x2AAB8EB3C   mov      x26, x21             
0x2AAB8EB40   b        0x2aab8eb60          
0x2AAB8EB44   mov      x0, x26              
0x2AAB8EB48   bl       0x2b00aaaa0          
0x2AAB8EB4C   mov      x20, x0              
0x2AAB8EB50   bl       0x2b00b4f40          
0x2AAB8EB54   mov      x26, x0              
0x2AAB8EB58   mov      x0, x20              
0x2AAB8EB5C   bl       0x2b00aaa90          
0x2AAB8EB60   mov      x21, x27             
0x2AAB8EB64   mov      x8, x23              
0x2AAB8EB68   mov      x23, x22             
0x2AAB8EB6C   mov      x22, x24             
0x2AAB8EB70   mov      x14, x19             
0x2AAB8EB74   ldur     x19, [x29, #-0x48]   
0x2AAB8EB78   sub      x9, x29, #0x28       
0x2AAB8EB7C   ldur     x10, [x9, #-0x100]   
0x2AAB8EB80   sub      x15, x29, #0x120     
0x2AAB8EB84   ldurb    w9, [x29, #-0xd8]    
0x2AAB8EB88   cmp      w9, #0x1             
0x2AAB8EB8C   b.ne     0x2aab8ebac          
0x2AAB8EB90   sub      x9, x29, #0x8        
0x2AAB8EB94   ldur     x9, [x9, #-0x100]    
0x2AAB8EB98   add      x1, x9, #0x20        
0x2AAB8EB9C   tst      x1, #0x7             
0x2AAB8EBA0   b.ne     0x2aab8ec3c          
0x2AAB8EBA4   ldr      x2, [x9, #0x10]      
0x2AAB8EBA8   b        0x2aab8ebb4          
0x2AAB8EBAC   add      x1, x15, #0x18       
0x2AAB8EBB0   ldur     x2, [x29, #-0xe0]    
0x2AAB8EBB4   ldurb    w9, [x29, #-0xa0]    
0x2AAB8EBB8   cmp      w9, #0x1             
0x2AAB8EBBC   b.ne     0x2aab8ebd8          
0x2AAB8EBC0   ldur     x9, [x29, #-0xd0]    
0x2AAB8EBC4   add      x3, x9, #0x20        
0x2AAB8EBC8   tst      x3, #0x7             
0x2AAB8EBCC   b.ne     0x2aab8ec40          
0x2AAB8EBD0   ldr      x4, [x9, #0x10]      
0x2AAB8EBD4   b        0x2aab8ebe4          
0x2AAB8EBD8   sub      x9, x29, #0x120      
0x2AAB8EBDC   add      x3, x9, #0x50        
0x2AAB8EBE0   ldur     x4, [x29, #-0xa8]    
0x2AAB8EBE4   add      x0, x26, x10         
0x2AAB8EBE8   mov      x20, x14             
0x2AAB8EBEC   mov      x5, x19              
0x2AAB8EBF0   mov      x17, #0xc051         
0x2AAB8EBF4   blraa    x28, x17             
0x2AAB8EBF8   cbz      x21, 0x2aab8ec1c     
0x2AAB8EBFC   ldr      x8, [x25, #0x20]!    
0x2AAB8EC00   mov      x0, x23              
0x2AAB8EC04   mov      x1, x19              
0x2AAB8EC08   mov      x2, x22              
0x2AAB8EC0C   mov      x17, x25             
0x2AAB8EC10   movk     x17, #0x48d8, lsl #48 
0x2AAB8EC14   blraa    x8, x17              
0x2AAB8EC18   mov      w21, #0x1            
0x2AAB8EC1C   sub      sp, x29, #0x50       
0x2AAB8EC20   ldp      x29, x30, [sp, #0x50] 
0x2AAB8EC24   ldp      x20, x19, [sp, #0x40] 
0x2AAB8EC28   ldp      x23, x22, [sp, #0x30] 
0x2AAB8EC2C   ldp      x25, x24, [sp, #0x20] 
0x2AAB8EC30   ldp      x27, x26, [sp, #0x10] 
0x2AAB8EC34   ldr      x28, [sp], #0x60     
0x2AAB8EC38   retab                         
0x2AAB8EC3C   brk      #0x1                 
0x2AAB8EC40   brk      #0x1                 
