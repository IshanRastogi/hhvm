// @generated by hh_manual
enum BitFlags: int as int {
  F1 = 1; // value 1
  F2 = BitFlags::F1 << 1; // value 2
  F3 = BitFlags::F2 << 1; // value 4
  F4 = 4 + 3; // value 7
}
