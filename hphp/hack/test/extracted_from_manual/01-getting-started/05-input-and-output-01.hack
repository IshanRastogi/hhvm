// @generated by hh_manual
use namespace HH\Lib\{File, IO};

async function main_async(): Awaitable<void> {
  // STDIN for CLI, or HTTP POST data
  $_in = IO\request_input();
  // STDOUT for CLI, or HTTP response
  $out = IO\request_output();

  $message = "Hello, world\n";
  await $out->writeAllAsync($message);

  // copy to a temporary file, automatically closed at scope exit
  using ($tf = File\temporary_file()) {
    $f = $tf->getHandle();

    await $f->writeAllAsync($message);

    $f->seek(0);
    $content = await $f->readAllAsync();
    await $out->writeAllAsync($content);
  }
}
