//
//  ContentView.swift
//  ToDo2
//
//  Created by Mehmet Erdem Keskin on 12.07.2022.
//

import SwiftUI

enum Priority: String, Identifiable, CaseIterable {
    
    var id: UUID {
        return UUID()
    }
    
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    
}
struct ContentView: View {
    
    @State private var title: String = ""
    @State private var selectedPriority: Priority = .medium
    @State private var animate:Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)]) private var allTasks: FetchedResults<Task>
    
    private func saveTask() {
        
        if textIsAppropriate() {
            do {
                let task = Task(context: viewContext)
                task.title = title
                task.priority = selectedPriority.rawValue
                task.order = (allTasks.last?.order ?? 0) + 1
                task.dateCreated = Date()
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        title = ""
    }
    
    private func textIsAppropriate() -> Bool {
        if title.count < 1 {
            return false
        }
        return true
    }
    
    
    private func styleForPriority(value: String) -> Color {
        let priority = Priority(rawValue: value)
        
        switch priority {
        case .low:
            return Color.green
        case .medium:
            return Color.orange
        case .high:
            return Color.red
        default:
            return Color.black
            
            
        }
        
        
    }
    
    
    private func updateTask(task: Task) {
        
        task.isDone.toggle()
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    private func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = allTasks[index]
            viewContext.delete(task)
            
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        if source.first! > destination{
            allTasks[source.first!].order = allTasks[destination].order - 1
            for i in destination...allTasks.count - 1{
                allTasks[i].order = allTasks[i].order + 1
            }
        }
        
        if source.first! < destination {
            allTasks[source.first!].order = allTasks[destination-1].order + 1
            for i in 0...destination-1 {
                allTasks[i].order = allTasks[i].order - 1
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }

        
    }
    
    private func addAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(
                Animation
                    .easeInOut(duration: 2.0)
                    .repeatForever()
            ) {
                animate.toggle()
            }
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                TextField("Enter task with a priority", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .background(Color(UIColor.systemBlue))
                    .shadow(color: .gray, radius: 3, x: 3, y: 3)
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(Priority.allCases) {
                        priority in
                        Text(priority.rawValue).tag(priority)
                        
                    }
                }.pickerStyle(.segmented)
                    .shadow(color: .gray, radius: 5, x: 5, y: 5)
                    .padding(2)
                
                if allTasks.isEmpty {
                    
                    Button("Add") {
                        
                        saveTask()
                    }
                    .padding(10)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .font(.headline)
                    .frame(maxWidth: animate ? 120 : 140)
                    .background(animate ? Color.red : Color.purple)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    
                    .onAppear(perform: addAnimation)
                    Spacer()
                    Text("There are no items!")
                        .font(.headline)
                        .padding(3)
                    Text("Select priority and add a task.")
                    Spacer()
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 120, height: 120, alignment: .center)
                        .scaleEffect(animate ? 1.1 : 1.0)
                        .shadow(color: animate ? Color.red.opacity(0.7) : Color.green.opacity(0.7), radius: animate ? 30 : 10, x: 0, y: animate ? 50 : 30)
                        .padding(30)
                    
                    
                    //Image eklenebilir
                } else {
                    Button("Add") {
                        
                        saveTask()
                    }
                    .padding(10)
                    .font(.headline)
                    .frame(maxWidth: 140)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: .blue, radius: 3, x: 3, y: 3)
                }
               
                
                if allTasks.isEmpty {
                    
                } else {
                    List {
                        
                        ForEach(allTasks) { task in
                            HStack {
                                Circle()
                                    .fill(styleForPriority(value: task.priority!))
                                    .frame(width: 15, height: 15)
                                    .shadow(color: .gray, radius: 1, x: 0, y: 1)
                                Spacer().frame(width: 20)
                                Text(task.title ?? "")
                                    .strikethrough(task.isDone)
                                Spacer()
                                Image(systemName: task.isDone ? "checkmark.circle": "circle")
                                    .foregroundColor(task.isDone ? .green : .red)
                                    .onTapGesture {
                                        updateTask(task: task)
                                    }
                            }
                            
                        }.onDelete(perform: deleteTask)
                            .onMove(perform: move)

                    }

                }
                Spacer()
                
            }
            .toolbar {
                EditButton()
            }
            .padding()
            // onappear(addAnimation) buraya koymuştum ama gerek yokmuş, button altına yeterli
            .navigationTitle("All Tasks")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = CoreDataManager.shared.persistentContainer
        ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
