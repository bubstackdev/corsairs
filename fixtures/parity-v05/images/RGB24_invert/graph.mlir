module {
  coreai.graph @main(%arg0: !coreai.image<<k24RGB> x 2 : i64 x 4 : i64> {coreai.name = "x"}) -> (!coreai.image<<k24RGB> x 2 : i64 x 4 : i64> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.constant dense<255> : tensor<2x4x3xui8>
    %1 = coreai.image_to_tensor %arg0 : <<k24RGB> x 2 : i64 x 4 : i64> -> tensor<2x4x3xui8>
    %2 = coreai.sub %0, %1 : (tensor<2x4x3xui8>, tensor<2x4x3xui8>) -> tensor<2x4x3xui8>
    %3 = coreai.tensor_to_image %2 : tensor<2x4x3xui8> -> <<k24RGB> x 2 : i64 x 4 : i64>
    coreai.output %3 : !coreai.image<<k24RGB> x 2 : i64 x 4 : i64>
  }
}

