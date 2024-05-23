export interface ExamplePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
