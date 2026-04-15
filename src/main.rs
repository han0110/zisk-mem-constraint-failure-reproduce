#![no_main]

use core::array::from_fn;
use ziskos::zisklib::blake2b_compress;

ziskos::entrypoint!(main);

fn main() {
    let n: u64 = ziskos::io::read();
    let mut hash = [0u8; 32];
    for _ in 0..n {
        hash = blake2b_256(&hash);
    }
    ziskos::io::write(&hash);
}

const IV: [u64; 8] = [
    0x6A09E667F3BCC908,
    0xBB67AE8584CAA73B,
    0x3C6EF372FE94F82B,
    0xA54FF53A5F1D36F1,
    0x510E527FADE682D1,
    0x9B05688C2B3E6C1F,
    0x1F83D9ABFB41BD6B,
    0x5BE0CD19137E2179,
];

fn blake2b_256(input: &[u8; 32]) -> [u8; 32] {
    let mut h = IV;
    h[0] ^= 0x0101_0020;
    let mut m = [0; 16];
    (0..4).for_each(|i| m[i] = u64::from_le_bytes(from_fn(|j| input[i * 8 + j])));
    blake2b_compress(12, &mut h, &m, &[32, 0], true);
    let mut o = [0u8; 32];
    (0..4).for_each(|i| o[i * 8..][..8].copy_from_slice(&h[i].to_le_bytes()));
    o
}
