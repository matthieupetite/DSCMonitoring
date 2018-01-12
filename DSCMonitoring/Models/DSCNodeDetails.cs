namespace DSCMonitoring.Models
{
    public class DSCNodeDetails :DSCNode
    {
        public string AgentId { get; set; }
        public string Time { get; set; }
        public string RebootRequested { get; set; }
        public string OperationType { get; set; }
        public string ResourcesInDesiredState { get; set; }
        public string ResourcesNotInDesiredState { get; set; }
        public double Duration { get; set; }
        public string DurationWithOverhead { get; set; }
        public int ResourceCountInDesiredState { get; set; }
        public string ErrorMessage { get; set; }
        public string RawStatusData { get; set; }
    }
}