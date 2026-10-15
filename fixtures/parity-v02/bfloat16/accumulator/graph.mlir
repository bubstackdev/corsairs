module {
  coreai.graph @main(%arg0: tensor<2x3xbf16> {coreai.name = "x"}, %arg1: !coreai.handle<tensor<2x3xbf16>> {coreai.name = "accumulator"}) -> (tensor<2x3xbf16> {coreai.name = "y"}, !coreai.token {coreai.name = "accumulator"}) attributes {__coreai_pure__} {
    %0 = coreai.create_token : !coreai.token
    %output, %out_token = coreai.read_handle %arg1, %0 : (<tensor<2x3xbf16>>, !coreai.token) -> (tensor<2x3xbf16>, !coreai.token)
    %1 = coreai.add %output, %arg0 : (tensor<2x3xbf16>, tensor<2x3xbf16>) -> tensor<2x3xbf16>
    %2 = coreai.write_handle %arg1, %1, %out_token : (<tensor<2x3xbf16>>, tensor<2x3xbf16>, !coreai.token) -> !coreai.token
    %output_0, %out_token_1 = coreai.read_handle %arg1, %2 : (<tensor<2x3xbf16>>, !coreai.token) -> (tensor<2x3xbf16>, !coreai.token)
    coreai.output %output_0, %out_token_1 : tensor<2x3xbf16>, !coreai.token
  }
}

