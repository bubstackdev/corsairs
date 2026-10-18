module {
  coreai.graph @main(%arg0: !coreai.image<<k32BGRA> x 2 : i64 x 4 : i64> {coreai.name = "x"}) -> (!coreai.image<<k32BGRA> x 2 : i64 x 4 : i64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.image_to_tensor %arg0 : <<k32BGRA> x 2 : i64 x 4 : i64> -> tensor<2x4x4xui8>
    %1 = coreai.tensor_to_image %0 : tensor<2x4x4xui8> -> <<k32BGRA> x 2 : i64 x 4 : i64>
    coreai.output %1 : !coreai.image<<k32BGRA> x 2 : i64 x 4 : i64>
  }
}

