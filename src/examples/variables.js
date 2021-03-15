function f(x0) {
    const x = x0 + 1
    if (x == 0) {
        const x = 3
        const y = x + 3
        if (y == 1) {
            return y + 1
        }
        else {
            const x = 4
            const y = x - 2
            return y - 1
        }
        const w = 2
        return w + x + y
    }
    return x + 1
}

console.assert(f(0) != 0)
console.log(f(0))