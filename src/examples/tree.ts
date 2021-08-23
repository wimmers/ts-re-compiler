interface node<T> {
    value: T,
    left: tree<T>,
    right: tree<T>
}

type leaf = null

type tree<T> = node<T> | leaf

const leaf = null

function node<T>(l: tree<T>, v: T, r: tree<T>) {
    return {
        value: v,
        left: l,
        right: r
    }
}

const node2: <T>(v: T, l?: tree<T>, r?: tree<T>) => node<T> = (v, l = null, r = null) => {
    return {
        value: v,
        left: l,
        right: r
    }
}

const n1 = node2(5)
const n2 = node2(4, n1)
const n3 = node2(3, n1, n2)
const t1 = node2(1, node2(2), n3)
const t2 = t1

const inorder: <T>(t: tree<T>) => T[] = (t) => {
    if (t == leaf) {
        return []
    }

    const { value, left, right } = t

    return [...inorder(left), value, ...inorder(right)]
}

// console.assert(inorder(t1) === [2, 1, 5, 3, 5, 4])
// console.assert(inorder(leaf) === [])
const l = inorder(n1.left)
// const l = [] as Number[]
const r = inorder(n1.right)
// const r = [] as Number[] // -> yields undefined
const v = [n1.value]
const x = [...[], n1.value, ...r]
// console.assert(inorder(n3) == [5,3,5,4])
// console.assert(inorder(t1) === [2, 1, 5, 3, 5, 4])
console.assert(inorder(t) == [1,2,3,4,5])
// const x = [...[], 5, ...[]]
// console.assert(x === [4])