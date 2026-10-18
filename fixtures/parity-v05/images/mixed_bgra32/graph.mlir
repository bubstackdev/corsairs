module {
  coreai.graph @main(%arg0: !coreai.image<<k32BGRA> x 2 : i64 x 4 : i64> {coreai.name = "x"}, %arg1: tensor<2x4x4xui8> {coreai.name = "t"}) -> (!coreai.image<<k32BGRA> x 2 : i64 x 4 : i64> {coreai.name = "y"}, tensor<2x4x4xui8> {coreai.name = "z"}) attributes {__coreai_pure__} {
    %0 = coreai.tensor_to_image %arg1 : tensor<2x4x4xui8> -> <<k32BGRA> x 2 : i64 x 4 : i64>
    %1 = coreai.image_to_tensor %arg0 : <<k32BGRA> x 2 : i64 x 4 : i64> -> tensor<2x4x4xui8>
    coreai.output %0, %1 : !coreai.image<<k32BGRA> x 2 : i64 x 4 : i64>, tensor<2x4x4xui8>
  }
}

