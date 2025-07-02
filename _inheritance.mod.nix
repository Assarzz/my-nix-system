{
  merge,
  configs,
  ...
}: {
  strategist = merge configs.universal configs.personal;
  pioneer256 = merge configs.universal configs.personal;
  vm1 = merge configs.universal configs.personal;
  igniter = merge configs.universal configs.personal;
}
