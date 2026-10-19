module {
  coreai.graph @main(%arg0: !coreai.image<<k24RGB> x 3 : i64 x 5 : i64> {coreai.name = "x"}) -> (tensor<3x5x3xui8> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.image_to_tensor %arg0 : <<k24RGB> x 3 : i64 x 5 : i64> -> tensor<3x5x3xui8>
    coreai.output %0 : tensor<3x5x3xui8>
  }
}

