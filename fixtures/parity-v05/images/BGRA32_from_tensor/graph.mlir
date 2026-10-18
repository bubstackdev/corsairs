module {
  coreai.graph @main(%arg0: tensor<2x4x4xui8> {coreai.name = "x"}) -> (!coreai.image<<k32BGRA> x 2 : i64 x 4 : i64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.tensor_to_image %arg0 : tensor<2x4x4xui8> -> <<k32BGRA> x 2 : i64 x 4 : i64>
    coreai.output %0 : !coreai.image<<k32BGRA> x 2 : i64 x 4 : i64>
  }
}

