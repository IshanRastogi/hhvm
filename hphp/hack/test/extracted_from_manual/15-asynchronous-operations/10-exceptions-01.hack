// @generated by hh_manual
async function exception_thrower(): Awaitable<void> {
  throw new \Exception("Return exception handle");
}

async function basic_exception(): Awaitable<void> {
  // the handle does not throw, but result will be an Exception objection.
  // Remember, this is the same as:
  //   $handle = exception_thrower();
  //   await $handle;
  await exception_thrower();
}

<<__EntryPoint>>
function main(): void {
  HH\Asio\join(basic_exception());
}
