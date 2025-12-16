 import { router } from '@kit.ArkUI';

// 1. 定义地址数据模型
interface AddressItem {
  id: number;
  name: string;
  phone: string;
  address: string;
  isDefault: boolean;
}

@Entry
@Component
struct AddressManage {
  // 2. 模拟地址列表数据 (根据图片内容)
  @State addressList: AddressItem[] = [
    {
      id: 1,
      name: "康刘勇",
      phone: "15219209751",
      address: "广东省广州市天河区珠吉街道100号",
      isDefault: true
    },
    {
      id: 2,
      name: "爱丽丝",
      phone: "16809801654",
      address: "北京市北京市东城区108街道",
      isDefault: false
    }
  ];

  // 3. 构建单个地址卡片
  @Builder
  AddressCard(item: AddressItem) {
    Row() {
      // 左侧信息区域
      Column({ space: 8 }) {
        // 第一行：姓名 + 电话 + [默认标签]
        Row({ space: 10 }) {
          Text(item.name)
            .fontSize(16)
            .fontColor('#333')
            .fontWeight(FontWeight.Bold)

          Text(item.phone)
            .fontSize(14)
            .fontColor('#666')

          // 如果是默认地址，显示标签
          if (item.isDefault) {
            Text("默认")
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor('#0C34BA') // 瑞幸蓝
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .borderRadius(4)
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        // 第二行：详细地址
        Text(item.address)
          .fontSize(14)
          .fontColor('#333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1) // 占满左边剩余空间
      .alignItems(HorizontalAlign.Start)

      // 右侧编辑图标
      // 这里假设您有 edit 图标，如果没有可以用 Text('✎') 代替，或者找一个图标资源
      // Image($r('app.media.ic_edit'))
      Text('✎') // 暂时用符号代替编辑图标，您可替换为 Image 组件
        .fontSize(20)
        .fontColor('#999')
        .padding(10)
        .onClick(() => {
          console.info('点击编辑地址:', item.id)
        })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 10 }) // 卡片间距
  }

  build() {
    Column() {
      // ============================================================
      // 1. 顶部导航栏 (保持不变，您提供的代码)
      // ============================================================
      Row() {
        Row() {
          Text("< 返回")
            .fontColor('#0C34BA')
            .fontSize(16)
        }
        .height('100%')
        .onClick(() => {
          router.back();
        })
        .padding({ left: 15 })

        Text("地址管理")
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ right: 60 })
      }
      .width("100%")
      .height(56)
      .backgroundColor(Color.White)
      .zIndex(2)

      // ============================================================
      // 2. 地址列表区域
      // ============================================================
      List() {
        ForEach(this.addressList, (item: AddressItem) => {
          ListItem() {
            this.AddressCard(item)
          }
        })
      }
      .width('100%')
      .layoutWeight(1) // 关键：让列表占据中间所有剩余空间
      .padding({ left: 15, right: 15, top: 15 }) // 列表整体的内边距

      // ============================================================
      // 3. 底部新增按钮
      // ============================================================
      Column() {
        Button("新增地址")
          .width('100%')
          .height(50)
          .backgroundColor('#0C34BA') // 瑞幸蓝
          .fontColor(Color.White)
          .fontSize(16)
          .borderRadius(25)
          .onClick(() => {
            // 这里处理跳转到新增页面
            router.pushUrl({ url: "pages/AddressAdd" })
            console.info("点击新增地址")
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 10 })
      .backgroundColor('#F5F5F5') // 保持底部背景一致

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5') // 整个页面的浅灰背景
  }
}