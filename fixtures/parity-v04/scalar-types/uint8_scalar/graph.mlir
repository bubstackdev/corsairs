module {
  coreai.graph @main(%arg0: tensor<ui8> {coreai.name = "x"}) -> (tensor<ui8> {coreai.name = "y"}) attributes {__coreai_pure__} {
    %0 = coreai.add %arg0, %arg0 : (tensor<ui8>, tensor<ui8>) -> tensor<ui8>
    coreai.output %0 : tensor<ui8>
  }
}

