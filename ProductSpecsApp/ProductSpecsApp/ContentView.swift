import SwiftUI

struct ContentView: View {
    @StateObject private var store = ProductStore()
    @State private var searchText = ""
    @State private var showingAdd = false
    @State private var showingBackupAlert = false

    var filteredProducts: [Product] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return store.products }
        return store.products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.spec.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText) ||
            $0.packageType.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredProducts.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "shippingbox")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("还没有产品")
                            .font(.headline)
                        Text("点右上角 + 添加第一条规格")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }

                ForEach(filteredProducts) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                            .environmentObject(store)
                    } label: {
                        ProductRow(product: product)
                            .environmentObject(store)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        store.delete(filteredProducts[index])
                    }
                }
            }
            .navigationTitle("产品规格库")
            .searchable(text: $searchText, prompt: "搜索产品/分类/包装")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("备份") {
                        store.exportJSONToClipboard()
                        showingBackupAlert = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                ProductEditView()
                    .environmentObject(store)
            }
            .alert("已复制备份", isPresented: $showingBackupAlert) {
                Button("好") {}
            } message: {
                Text("产品 JSON 已复制到剪贴板。你可以粘贴到备忘录或文件里保存。")
            }
        }
    }
}

struct ProductRow: View {
    @EnvironmentObject var store: ProductStore
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 5) {
                Text(product.name.isEmpty ? "未命名产品" : product.name)
                    .font(.headline)
                Text([product.category, product.spec, product.packageType].filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("尺寸：\(format(product.length))×\(format(product.width))×\(format(product.height)) cm")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("方数：\(String(format: "%.5f", product.cbm)) m³")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder var thumbnail: some View {
        if let first = product.imageFileNames.first,
           let image = UIImage(contentsOfFile: store.imageURL(first).path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 74, height: 74)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.15))
                .frame(width: 74, height: 74)
                .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
        }
    }

    func format(_ value: Double) -> String { String(format: "%.1f", value) }
}
