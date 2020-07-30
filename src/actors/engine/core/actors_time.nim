import a_core_types

template delta*(this: SystemTime): float =
  this.deltaCap * this.scale