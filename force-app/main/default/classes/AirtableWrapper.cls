public class AirtableWrapper {
  public List<Records> records;
  public class Records {
    public String id;
    public Fields fields;
  }
  public class Fields {
    public String Name;
    public String Reference;
    public String Discipline;
    public String Size;
    public String Color;
    public String Category;
  }
}
