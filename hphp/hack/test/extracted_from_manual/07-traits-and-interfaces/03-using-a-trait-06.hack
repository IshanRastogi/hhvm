// @generated by hh_manual
trait T1 {
  const FOO = 'one';
}

trait T2 {
  const FOO = 'two';
}

class A { use T1, T2; }

<<__EntryPoint>>
function main() : void {
  \var_dump(A::FOO);
}
