using AzureSQL.ToDo;
using System;
using System.Collections.Generic;

namespace AzureSamples.FunctionApp
{
    public static class StaticDbStore
    {
        public static List<ToDoItem> GetAllTodoItems()
        {
            return new List<ToDoItem>   {
            new ToDoItem
            {
                Id = "1",
                Order = 1,
                Title = "Complete Task 1",
                Url = "https://example.com/task1",
                Completed = true
            },
            new ToDoItem
            {
                Id = "2",
                Order = 2,
                Title = "Review Task 2",
                Url = "https://example.com/task2",
                Completed = false
            },
            new ToDoItem
            {
               Id = "3",
                Order = 3,
                Title = "Start Task 3",
                Url = "https://example.com/task3",
                Completed = false
            },
            new ToDoItem
            {
               Id = "4",
                Order = 4,
                Title = "Update Task 4",
                Url = "https://example.com/task4",
                Completed = false
            },
            new ToDoItem
            {
                Id = "5",
                Order = 5,
                Title = "Finish Task 5",
                Url = "https://example.com/task5",
                Completed = true
            },
            new ToDoItem
            {
                Id = "6",
                Order = 6,
                Title = "Test Task 6",
                Url = "https://example.com/task6",
                Completed = false
            },
            new ToDoItem
            {
                Id = "7",
                Order = 7,
                Title = "Submit Task 7",
                Url = "https://example.com/task7",
                Completed = true
            },
            new ToDoItem
            {
                Id = "8",
                Order = 8,
                Title = "Create Task 8",
                Url = "https://example.com/task8",
                Completed = false
            },
            new ToDoItem
            {
                Id = "9",
                Order = 9,
                Title = "Organize Task 9",
                Url = "https://example.com/task9",
                Completed = true
            },
            new ToDoItem
            {
                Id = "10",
                Order = 10,
                Title = "Implement Task 10",
                Url = "https://example.com/task10",
                Completed = false
            }
          };
        }
    }
}
