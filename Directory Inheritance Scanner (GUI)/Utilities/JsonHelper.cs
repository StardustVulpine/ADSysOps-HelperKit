using System;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Utilities
{
    public class JsonHelper {
        public static object Load(string path) {
            var content = File.ReadAllText(path);
            var doc = JsonDocument.Parse(content);
            return doc.RootElement.Clone(); 
        }

        public static void Export(string path, object data) {
            var options = new JsonSerializerOptions {
                WriteIndented = true
            };
            var json = JsonSerializer.Serialize(data, options);
            File.WriteAllText(path, json);
        }
    }

}