module {
  coreai.graph @main(%arg0: tensor<bf16> {coreai.name = "x"}) -> (tensor<bf16> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<bf16>, tensor<bf16>) -> tensor<bf16>
    coreai.output %0 : tensor<bf16>
  }
}

