


async function main() {
  const res = await fetch(new URL("./hexmvt.txt", import.meta.url));

  console.log(res.toString());
}

main();