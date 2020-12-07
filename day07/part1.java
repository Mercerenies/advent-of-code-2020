
import java.util.*;
import java.util.regex.*;
import java.nio.file.*;
import java.io.IOException;

public class part1 {

  public static class DAGNode {
    public final String label;
    public final ArrayList<ChildNode> children;

    public DAGNode(String label) {
      this.label = label;
      this.children = new ArrayList<ChildNode>();
    }

  }

  public static class ChildNode {
    public final int amount;
    public final DAGNode node;

    public ChildNode(int amount, DAGNode node) {
      this.amount = amount;
      this.node = node;
    }

  }

  public static class Quantity {
    public final int amount;
    public final String label;

    public Quantity(int amount, String label) {
      this.amount = amount;
      this.label = label;
    }

  }

  public static void main(String[] args) throws IOException {
    HashMap<String, DAGNode> nodes = new HashMap<String, DAGNode>();
    List<String> lines = Files.readAllLines(Paths.get("input.txt"));

    for (String line : lines) {
      String label = getLabel(line);
      nodes.put(label, new DAGNode(label));
    }

    for (String line : lines) {
      String label = getLabel(line);
      List<Quantity> children = getChildren(line);
      DAGNode node = nodes.get(label);
      for (Quantity q : children) {
        DAGNode child = nodes.get(q.label);
        node.children.add(new ChildNode(q.amount, child));
      }
    }

    int count = 0;
    for (DAGNode node : nodes.values()) {
      if (canHold("shiny gold", node))
        count += 1;
    }
    System.out.println(count);

  }

  public static boolean canHold(String label, DAGNode node) {
    for (ChildNode c : node.children) {
      if (c.node.label.equals(label))
        return true;
      else if (canHold(label, c.node))
        return true;
    }
    return false;
  }

  public static String getLabel(String line) {
    Pattern ptn = Pattern.compile("^\\w+ \\w+");
    Matcher m = ptn.matcher(line);
    m.find();
    return m.group();
  }

  public static List<Quantity> getChildren(String line) {
    Pattern ptn = Pattern.compile("(\\d+) (\\w+ \\w+)");
    Matcher m = ptn.matcher(line);
    ArrayList<Quantity> arr = new ArrayList<Quantity>();
    while (m.find()) {
      int amount = Integer.parseInt(m.group(1));
      String label = m.group(2);
      arr.add(new Quantity(amount, label));
    }
    return arr;
  }

}
