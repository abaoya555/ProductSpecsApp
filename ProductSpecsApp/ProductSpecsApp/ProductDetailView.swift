import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var store: ProductStore
    @Environment(\.dismiss) private var dismiss

    @State var product: Product
    @State private var showingEdit = false
    @State private var copied = false

    var specText: String {
        """
        产品：\(product.name)
        规格：\(product.spec)
        分类：\(product.category)
        包装：\(product.packageType)
        尺寸：\(product.length) × \(product.width) × \(product.height) cm
        方数：\(String(format: "%.5f", product.cbm)) m³
        备注：\(product.remark)
        """
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !product.imageFileNames.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(product.imageFileNames, id: \.self) { name in
                                if let image = UIImage(contentsOfFile: store.imageURL(name).path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 280, height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                }
                            }
                        }
                    }
                }

                GroupBox("产品规格") {
                    VStack(alignment: .leading, spacing: 12) {
                        row("产品", product.name)
                        row("规格", product.spec)
                        row("分类", product.category)
                        row("包装", product.packageType)
                        row("尺寸", "\(product.length) × \(product.width) × \(product.height) cm")
                        row("方数", "\(String(format: "%.5f", product.cbm)) m³")
                        row("备注", product.remark.isEmpty ? "无" : product.remark)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    UIPasteboard.general.string = specText
                    copied = true
                } label: {
                    Label("复制客户规格", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(role: .destructive) {
                    store.delete(product)
                    dismiss()
                } label: {
                    Label("删除产品", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle(product.name)
        .toolbar {
            Button("编辑") { showingEdit = true }
        }
        .sheet(isPresented: $showingEdit, onDismiss: reloadProduct) {
            ProductEditView(editingProduct: product)
                .environmentObject(store)
        }
        .alert("已复制", isPresented: $copied) {
            Button("好") {}
        }
    }

    func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title).foregroundStyle(.secondary).frame(width: 56, alignment: .leading)
            Text(value)
            Spacer()
        }
    }

    func reloadProduct() {
        if let latest = store.products.first(where: { $0.id == product.id }) {
            product = latest
        }
    }
}
