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
0x2AAB40874   pacibsp                       
0x2AAB40878   orr      x29, x29, #0x1000000000000000 
0x2AAB4087C   sub      sp, sp, #0x60        
0x2AAB40880   str      x27, [sp, #0x10]     
0x2AAB40884   stp      x26, x25, [sp, #0x18] 
0x2AAB40888   stp      x24, x23, [sp, #0x28] 
0x2AAB4088C   stp      x21, x19, [sp, #0x38] 
0x2AAB40890   stp      x29, x30, [sp, #0x50] 
0x2AAB40894   add      x16, sp, #0x48       
0x2AAB40898   movk     x16, #0xc31a, lsl #48 
0x2AAB4089C   mov      x17, x22             
0x2AAB408A0   pacdb    x17, x16             
0x2AAB408A4   str      x17, [sp, #0x48]     
0x2AAB408A8   add      x29, sp, #0x50       
0x2AAB408AC   ldr      x20, [x22, #0x18]    
0x2AAB408B0   mov      x0, #0x0             
0x2AAB408B4   bl       _$s13CoreAIRuntime27InferenceFunctionDescriptorVMa 
0x2AAB408B8   ldrsw    x8, [x0, #0x14]      
0x2AAB408BC   add      x20, x20, x8         
0x2AAB408C0   mov      x0, #0x0             
0x2AAB408C4   bl       0x2ab05337c          
0x2AAB408C8   ldrsw    x8, [x0, #0x14]      
0x2AAB408CC   add      x8, x20, x8          
0x2AAB408D0   ldp      x24, x25, [x8]       
0x2AAB408D4   ldr      x26, [x8, #0x10]     
0x2AAB408D8   ldr      w27, [x8, #0x18]     
0x2AAB408DC   bl       0x2ab0548e4          
0x2AAB408E0   mov      x20, x0              
0x2AAB408E4   mov      x19, x1              
0x2AAB408E8   mov      x21, x2              
0x2AAB408EC   mov      x23, x3              
0x2AAB408F0   mov      x0, x24              
0x2AAB408F4   mov      x1, x25              
0x2AAB408F8   mov      x2, x26              
0x2AAB408FC   mov      x3, x27              
0x2AAB40900   bl       0x2ab0570a8          
0x2AAB40904   tbnz     w0, #0x1f, 0x2aab40adc 
0x2AAB40908   mov      x1, x20              
0x2AAB4090C   mov      x2, x19              
0x2AAB40910   mov      x3, x21              
0x2AAB40914   mov      x4, x23              
0x2AAB40918   bl       0x2aae93364          
0x2AAB4091C   and      x8, x3, #0xff00000000 
0x2AAB40920   mov      x9, #0x100000000     
0x2AAB40924   cmp      x8, x9               
0x2AAB40928   b.eq     0x2aab40ae4          
0x2AAB4092C   mov      w8, #0x1             
0x2AAB40930   str      x8, [sp]             
0x2AAB40934   mov      x4, x20              
0x2AAB40938   mov      x5, x19              
0x2AAB4093C   mov      x6, x21              
0x2AAB40940   mov      x7, x23              
0x2AAB40944   bl       0x2ab053644          
0x2AAB40948   tbz      w0, #0x0, 0x2aab409b0 
0x2AAB4094C   ldr      x20, [x22, #0x10]    
0x2AAB40950   cbz      x20, 0x2aab409f0     
0x2AAB40954   ldrb     w8, [x22, #0x30]     
0x2AAB40958   cmp      w8, #0x1             
0x2AAB4095C   b.ne     0x2aab40a58          
0x2AAB40960   bl       0x2aab4c578          
0x2AAB40964   mov      x19, x1              
0x2AAB40968   mov      x21, x2              
0x2AAB4096C   bl       0x2b00aad10          
0x2AAB40970   mov      x0, x19              
0x2AAB40974   bl       0x2b00aaa90          
0x2AAB40978   adds     x19, x21, #0x1       
0x2AAB4097C   b.hs     0x2aab40ae0          
0x2AAB40980   adrp     x8, 150702           ; 0x2cf7ee000
0x2AAB40984   ldr      x8, [x8, #0x3b0]     
0x2AAB40988   add      x23, x20, x8         
0x2AAB4098C   ldr      x21, [x23]           
0x2AAB40990   mov      x0, x21              
0x2AAB40994   bl       0x2b00aad20          
0x2AAB40998   mov      x1, x19              
0x2AAB4099C   bl       0x2aab4e0e4          
0x2AAB409A0   mov      x0, x21              
0x2AAB409A4   bl       0x2b00aad10          
0x2AAB409A8   str      x19, [x23, #0x10]    
0x2AAB409AC   b        0x2aab40a60          
0x2AAB409B0   mov      x0, x22              
0x2AAB409B4   ldr      x1, [x0, #0x8]!      
0x2AAB409B8   ldp      x29, x30, [sp, #0x50] 
0x2AAB409BC   ldp      x21, x19, [sp, #0x38] 
0x2AAB409C0   ldp      x24, x23, [sp, #0x28] 
0x2AAB409C4   ldp      x26, x25, [sp, #0x18] 
0x2AAB409C8   ldr      x27, [sp, #0x10]     
0x2AAB409CC   and      x29, x29, #0xefffffffffffffff 
0x2AAB409D0   add      sp, sp, #0x60        
0x2AAB409D4   autibsp                       
0x2AAB409D8   eor      x16, x30, x30, lsl #1 
0x2AAB409DC   tbz      x16, #0x3e, 0x2aab409e4 
0x2AAB409E0   brk      #0xc471              
0x2AAB409E4   mov      x16, x0              
0x2AAB409E8   movk     x16, #0xd707, lsl #48 
0x2AAB409EC   braa     x1, x16              
0x2AAB409F0   adrp     x8, 1358             ; 0x2ab08e000
0x2AAB409F4   add      x8, x8, #0x160       
0x2AAB409F8   sub      x8, x8, #0x20        
0x2AAB409FC   str      wzr, [sp, #0x8]      
0x2AAB40A00   mov      w9, #0x18f           
0x2AAB40A04   str      x9, [sp]             
0x2AAB40A08   adrp     x0, 1361             ; 0x2ab091000
0x2AAB40A0C   add      x0, x0, #0x120       
0x2AAB40A10   adrp     x5, 1358             ; 0x2ab08e000
0x2AAB40A14   add      x5, x5, #0x60        
0x2AAB40A18   orr      x4, x8, #0x8000000000000000 
0x2AAB40A1C   mov      w1, #0xb             
0x2AAB40A20   mov      w2, #0x2             
0x2AAB40A24   mov      x3, #0x37            
0x2AAB40A28   movk     x3, #0xd000, lsl #48 
0x2AAB40A2C   mov      w6, #0x2a            
0x2AAB40A30   mov      w7, #0x2             
0x2AAB40A34   bl       0x2b00ab0d0          
0x2AAB40A38   ldp      x29, x30, [sp, #0x50] 
0x2AAB40A3C   ldp      x21, x19, [sp, #0x38] 
0x2AAB40A40   ldp      x24, x23, [sp, #0x28] 
0x2AAB40A44   ldp      x26, x25, [sp, #0x18] 
0x2AAB40A48   ldr      x27, [sp, #0x10]     
0x2AAB40A4C   and      x29, x29, #0xefffffffffffffff 
0x2AAB40A50   add      sp, sp, #0x60        
0x2AAB40A54   retab                         
0x2AAB40A58   bl       0x2aab4c3a4          
0x2AAB40A5C   ldr      x19, [x22, #0x20]    
0x2AAB40A60   adrp     x8, 1332             ; 0x2ab074000
0x2AAB40A64   add      x8, x8, #0xe50       ; _$s13CoreAIRuntime13ComputeStreamC16reachedSyncPointyys6UInt64VYaFTu
0x2AAB40A68   ldr      w0, [x8, #0x4]       
0x2AAB40A6C   bl       0x2b00b2aa0          
0x2AAB40A70   mov      x17, x22             
0x2AAB40A74   mov      x16, x0              
0x2AAB40A78   movk     x16, #0xbda2, lsl #48 
0x2AAB40A7C   str      x0, [x22, #0x28]     
0x2AAB40A80   pacda    x17, x16             
0x2AAB40A84   str      x17, [x0]            
0x2AAB40A88   add      x8, x0, #0x8         
0x2AAB40A8C   adrp     x16, 0               ; 0x2aab40000
0x2AAB40A90   add      x16, x16, #0xae8     
0x2AAB40A94   mov      x17, x8              
0x2AAB40A98   movk     x17, #0xd707, lsl #48 
0x2AAB40A9C   pacia    x16, x17             
0x2AAB40AA0   str      x16, [x0, #0x8]      
0x2AAB40AA4   mov      x22, x0              
0x2AAB40AA8   mov      x0, x19              
0x2AAB40AAC   ldp      x29, x30, [sp, #0x50] 
0x2AAB40AB0   ldp      x21, x19, [sp, #0x38] 
0x2AAB40AB4   ldp      x24, x23, [sp, #0x28] 
0x2AAB40AB8   ldp      x26, x25, [sp, #0x18] 
0x2AAB40ABC   ldr      x27, [sp, #0x10]     
0x2AAB40AC0   and      x29, x29, #0xefffffffffffffff 
0x2AAB40AC4   add      sp, sp, #0x60        
0x2AAB40AC8   autibsp                       
0x2AAB40ACC   eor      x16, x30, x30, lsl #1 
0x2AAB40AD0   tbz      x16, #0x3e, 0x2aab40ad8 
0x2AAB40AD4   brk      #0xc471              
0x2AAB40AD8   b        _$s13CoreAIRuntime13ComputeStreamC16reachedSyncPointyys6UInt64VYaF 
0x2AAB40ADC   brk      #0x1                 
0x2AAB40AE0   brk      #0x1                 
0x2AAB40AE4   brk      #0x1                 
0x2AAB40AE8   pacibsp                       
0x2AAB40AEC   orr      x29, x29, #0x1000000000000000 
0x2AAB40AF0   sub      sp, sp, #0x20        
0x2AAB40AF4   stp      x29, x30, [sp, #0x10] 
0x2AAB40AF8   add      x16, sp, #0x8        
0x2AAB40AFC   movk     x16, #0xc31a, lsl #48 
0x2AAB40B00   mov      x17, x22             
0x2AAB40B04   pacdb    x17, x16             
0x2AAB40B08   str      x17, [sp, #0x8]      
0x2AAB40B0C   add      x29, sp, #0x10       
0x2AAB40B10   mov      x17, x22             
0x2AAB40B14   sub      x8, x29, #0x8        
0x2AAB40B18   movk     x8, #0xc31a, lsl #48 
0x2AAB40B1C   ldr      x9, [x22]            
0x2AAB40B20   mov      x16, x9              
0x2AAB40B24   movk     x17, #0xbda2, lsl #48 
0x2AAB40B28   autda    x16, x17             
0x2AAB40B2C   mov      x17, x16             
0x2AAB40B30   xpacd    x17                  
0x2AAB40B34   cmp      x16, x17             
0x2AAB40B38   b.eq     0x2aab40b40          
0x2AAB40B3C   brk      #0xc472              
0x2AAB40B40   mov      x17, x16             
0x2AAB40B44   mov      x16, x8              
0x2AAB40B48   pacda    x17, x16             
0x2AAB40B4C   sub      x8, x29, #0x8        
0x2AAB40B50   str      x17, [x8]            
0x2AAB40B54   mov      x16, x9              
0x2AAB40B58   mov      x17, x22             
0x2AAB40B5C   movk     x17, #0xbda2, lsl #48 
0x2AAB40B60   autda    x16, x17             
0x2AAB40B64   ldr      x0, [x16, #0x28]     
0x2AAB40B68   ldr      x16, [x22]           
0x2AAB40B6C   mov      x17, x22             
0x2AAB40B70   movk     x17, #0xbda2, lsl #48 
0x2AAB40B74   autda    x16, x17             
0x2AAB40B78   mov      x17, x16             
0x2AAB40B7C   xpacd    x17                  
0x2AAB40B80   cmp      x16, x17             
0x2AAB40B84   b.eq     0x2aab40b8c          
0x2AAB40B88   brk      #0xc472              
0x2AAB40B8C   mov      x22, x16             
0x2AAB40B90   bl       0x2b00b2ac0          
0x2AAB40B94   mov      x0, x22              
0x2AAB40B98   ldr      x1, [x0, #0x8]!      
0x2AAB40B9C   ldp      x29, x30, [sp, #0x10] 
0x2AAB40BA0   and      x29, x29, #0xefffffffffffffff 
0x2AAB40BA4   add      sp, sp, #0x20        
0x2AAB40BA8   autibsp                       
0x2AAB40BAC   eor      x16, x30, x30, lsl #1 
0x2AAB40BB0   tbz      x16, #0x3e, 0x2aab40bb8 
0x2AAB40BB4   brk      #0xc471              
0x2AAB40BB8   mov      x16, x0              
0x2AAB40BBC   movk     x16, #0xd707, lsl #48 
0x2AAB40BC0   braa     x1, x16              
