// @generated by hh_manual
enum class Foo: string {
  string BAR = 'BAZ';
}

function do_stuff(HH\MemberOf<Foo, string> $value): void {
  var_dump($value);
}

function main(): void {
  do_stuff(Foo::BAR); // ok
}
