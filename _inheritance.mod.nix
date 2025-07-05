{
  merge,
  configs,
  ...
}: {
  strategist = merge configs.universal configs.personal;
  pioneer = merge configs.universal configs.personal;
  igniter = merge configs.universal configs.personal;
  insomniac = configs.universal;
}
