using System;

namespace AzureSQL.ToDo
{
    public class ToDoItem
    {
        public string Id { get; set; }
        public int? Order { get; set; }
        public string Title { get; set; }
        public string Url { get; set; }
        public bool? Completed { get; set; }
    }
}
