module {
  coreai.graph @main(%arg0: !coreai.image<<k32BGRA> x 2 : i64 x 4 : i64> {coreai.name = "x"}) -> (tensor<2x4x4xui8> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.image_to_tensor %arg0 : <<k32BGRA> x 2 : i64 x 4 : i64> -> tensor<2x4x4xui8>
    coreai.output %0 : tensor<2x4x4xui8>
  }
}

