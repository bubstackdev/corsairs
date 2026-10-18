module {
  coreai.graph @main(%arg0: !coreai.image<<k32ARGB> x 2 : i64 x 4 : i64> {coreai.name = "x"}) -> (!coreai.image<<k32ARGB> x 2 : i64 x 4 : i64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<255> : tensor<2x4x4xui8>
    %1 = coreai.image_to_tensor %arg0 : <<k32ARGB> x 2 : i64 x 4 : i64> -> tensor<2x4x4xui8>
    %2 = coreai.sub %0, %1 : (tensor<2x4x4xui8>, tensor<2x4x4xui8>) -> tensor<2x4x4xui8>
    %3 = coreai.tensor_to_image %2 : tensor<2x4x4xui8> -> <<k32ARGB> x 2 : i64 x 4 : i64>
    coreai.output %3 : !coreai.image<<k32ARGB> x 2 : i64 x 4 : i64>
  }
}

