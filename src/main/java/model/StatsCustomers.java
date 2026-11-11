package model;

import java.io.Serializable;

public class StatsCustomers implements Serializable {
    private static final long serialVersionUID = 1L;

    private Customers1 customer;
    private int totalTicket;
    private float totalSpent;

    public StatsCustomers() {
    }

    public StatsCustomers(Customers1 customer, int totalTicket, float totalSpent) {
        this.customer = customer;
        this.totalTicket = totalTicket;
        this.totalSpent = totalSpent;
    }

    public Customers1 getCustomer() {
        return customer;
    }

    public void setCustomer(Customers1 customer) {
        this.customer = customer;
    }

    public int getTotalTicket() {
        return totalTicket;
    }

    public void setTotalTicket(int totalTicket) {
        this.totalTicket = totalTicket;
    }

    public float getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(float totalSpent) {
        this.totalSpent = totalSpent;
    }
}

