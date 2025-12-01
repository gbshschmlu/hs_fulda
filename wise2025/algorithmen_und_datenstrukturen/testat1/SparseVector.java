public class SparseVector {

    private static class Node {
        int index;
        double value;
        Node next;

        Node(int index, double value, Node next) {
            this.index = index;
            this.value = value;
            this.next = next;
        }
    }

    private Node head;
    private int length;

    public SparseVector() {
        this.head = new Node(-1, 0.0, null);
        this.length = 0;
    }

    public SparseVector(int n) {
        if (n < 0) {
            throw new IllegalArgumentException("Länge darf nicht negativ sein");
        }
        this.head = new Node(-1, 0.0, null);
        this.length = n;
    }

    private void checkIndex(int index) {
        if (index < 0 || index >= length) {
            throw new IndexOutOfBoundsException("Index " + index + " außerhalb [0, " + length + ")");
        }
    }

    public void setElement(int index, double value) {
        checkIndex(index);

        if (value == 0.0) {
            removeElement(index);
            return;
        }

        Node prev = head;
        Node curr = head.next;

        while (curr != null && curr.index < index) {
            prev = curr;
            curr = curr.next;
        }

        if (curr != null && curr.index == index) {
            curr.value = value;
        } else {
            Node newNode = new Node(index, value, curr);
            prev.next = newNode;
        }
    }

    public double getElement(int index) {
        checkIndex(index);

        Node curr = head.next;
        while (curr != null && curr.index < index) {
            curr = curr.next;
        }
        if (curr != null && curr.index == index) {
            return curr.value;
        }
        return 0.0;
    }

    public void removeElement(int index) {
        checkIndex(index);

        Node prev = head;
        Node curr = head.next;

        while (curr != null && curr.index < index) {
            prev = curr;
            curr = curr.next;
        }

        if (curr != null && curr.index == index) {
            prev.next = curr.next;
        }
    }

    public int getLength() {
        return length;
    }

    public boolean equals(SparseVector other) {
        if (other == null) {
            return false;
        }
        if (this.length != other.length) {
            return false;
        }

        Node a = this.head.next;
        Node b = other.head.next;

        while (a != null && b != null) {
            if (a.index != b.index) {
                return false;
            }
            if (a.value != b.value) {
                return false;
            }
            a = a.next;
            b = b.next;
        }

        return a == null && b == null;
    }

    public void add(SparseVector other) {
        if (other == null) {
            throw new IllegalArgumentException("Other vector must not be null");
        }
        if (this.length != other.length) {
            throw new IllegalArgumentException("Vectors must have the same length");
        }

        Node prev = this.head;
        Node curr = this.head.next;
        Node otherCurr = other.head.next;

        while (otherCurr != null) {
            int idx = otherCurr.index;
            double val = otherCurr.value;

            while (curr != null && curr.index < idx) {
                prev = curr;
                curr = curr.next;
            }

            if (curr != null && curr.index == idx) {
                curr.value += val;

                if (curr.value == 0.0) {
                    prev.next = curr.next;
                    curr = prev.next;
                } else {
                    prev = curr;
                    curr = curr.next;
                }
            } else {
                Node newNode = new Node(idx, val, curr);
                prev.next = newNode;
                prev = newNode;
            }

            otherCurr = otherCurr.next;
        }
    }
}
