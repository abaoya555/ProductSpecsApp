import SwiftUI

struct ProductEditView: View {
    @EnvironmentObject var store: ProductStore
    @Environment(\.dismiss) private var dismiss

    var editingProduct: Product?

    @State private var name = ""
    @State private var spec = ""
    @State private var category = ""
    @State private var packageType = ""
    @State private var length = ""
    @State private var width = ""
    @State private var height = ""
    @State private var remark = ""
    @State private var imageFileNames: [String] = []
    @State private var showingImagePicker = false

    var cbm: Double {
        (Double(length) ?? 0) * (Double(width) ?? 0) * (Double(height) ?? 0) / 1_000_000
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("图片") {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(imageFileNames, id: \.self) { name in
                                if let image = UIImage(contentsOfFile: store.imageURL(name).path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 92, height: 92)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            Button {
                                showingImagePicker = true
                            } label: {
                                VStack {
                                    Image(systemName: "plus")
                                    Text("加图")
                                }
                                .frame(width: 92, height: 92)
                                .background(.gray.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }

                Section("基础信息") {
                    TextField("产品名，例如：菠菜", text: $name)
                    TextField("规格，例如：4kg / 200g×20", text: $spec)
                    TextField("分类，例如：叶菜类", text: $category)
                    TextField("包装，例如：纸箱 / 泡沫箱", text: $packageType)
                }

                Section("尺寸 cm") {
                    TextField("长", text: $length).keyboardType(.decimalPad)
                    TextField("宽", text: $width).keyboardType(.decimalPad)
                    TextField("高", text: $height).keyboardType(.decimalPad)
                    Text("自动方数：\(String(format: "%.5f", cbm)) m³")
                        .foregroundStyle(.blue)
                }

                Section("备注") {
                    TextField("备注", text: $remark, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(editingProduct == nil ? "添加产品" : "编辑产品")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveProduct() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker { image in
                    if let fileName = store.saveImage(image) {
                        imageFileNames.append(fileName)
                    }
                }
            }
            .onAppear { loadEditingProduct() }
        }
    }

    func loadEditingProduct() {
        guard let product = editingProduct else { return }
        name = product.name
        spec = product.spec
        category = product.category
        packageType = product.packageType
        length = String(product.length)
        width = String(product.width)
        height = String(product.height)
        remark = product.remark
        imageFileNames = product.imageFileNames
    }

    func saveProduct() {
        let product = Product(
            id: editingProduct?.id ?? UUID(),
            name: name,
            spec: spec,
            category: category,
            packageType: packageType,
            length: Double(length) ?? 0,
            width: Double(width) ?? 0,
            height: Double(height) ?? 0,
            remark: remark,
            imageFileNames: imageFileNames,
            createdAt: editingProduct?.createdAt ?? Date(),
            updatedAt: Date()
        )
        if editingProduct == nil { store.add(product) } else { store.update(product) }
        dismiss()
    }
}
