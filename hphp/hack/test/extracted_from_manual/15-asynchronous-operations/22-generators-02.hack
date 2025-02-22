// @generated by hh_manual
const int HALF_SECOND = 500000; // microseconds

async function get_name_string(int $id): Awaitable<string> {
  // simulate fetch to database where we would actually use $id
  await \HH\Asio\usleep(HALF_SECOND);
  return \str_shuffle("ABCDEFG");
}

async function generate(): AsyncGenerator<int, string, int> {
  $id = yield 0 => ''; // initialize $id
  // $id is a ?int; you can pass null to send()
  while ($id is nonnull) {
    $name = await get_name_string($id);
    $id = yield $id => $name; // key/string pair
  }
}

async function associate_ids_to_names(vec<int> $ids): Awaitable<void> {
  $async_generator = generate();
  // You have to call next() before you send. So this is the priming step and
  // you will get the initialization result from generate()
  $result = await $async_generator->next();
  \var_dump($result);

  foreach ($ids as $id) {
    // $result will be an array of ?int and string
    $result = await $async_generator->send($id);
    \var_dump($result);
  }
}

<<__EntryPoint>>
function run(): void {
  $ids = vec[1, 2, 3, 4];
  \HH\Asio\join(associate_ids_to_names($ids));
}
