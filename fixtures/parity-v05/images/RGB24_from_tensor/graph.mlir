module {
  coreai.graph @main(%arg0: tensor<2x4x3xui8> {coreai.name = "x"}) -> (!coreai.image<<k24RGB> x 2 : i64 x 4 : i64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.tensor_to_image %arg0 : tensor<2x4x3xui8> -> <<k24RGB> x 2 : i64 x 4 : i64>
    coreai.output %0 : !coreai.image<<k24RGB> x 2 : i64 x 4 : i64>
  }
}

