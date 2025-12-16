//自定义组件 -- 我的
import { router } from '@kit.ArkUI';

@Component
export default struct My {
  @State menuList: string[] = [
    "个人资料",
    "我的订单",
    "我的收藏",
    "地址管理",
    "安全中心"
  ]

  @Builder
  SettingCell(title: string, showBorder: boolean) {
    Row() {
      Text(title).fontSize(16).fontColor('#333333')
      Blank()
      Text('>').fontSize(18).fontColor('#999999')
    }
    .width('100%')
    .height(55)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      console.info(`点击了: ${title}`)
    })
    // 【修改点1】列表项背景改为透明，否则它会挡住大卡片的半透明效果
    .backgroundColor(Color.Transparent)

    if (showBorder) {
      Divider()
        .color('#F0F0F0') // 分割线颜色也可以稍微淡一点，比如 'rgba(0,0,0,0.05)'
        .strokeWidth(1)
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        // 底层：背景图
        Column()
          .width('100%')
          .height(260)
          .backgroundColor('#4A3B32')

        // 上层：半透明内容卡片
        Column() {
          // --- A. 用户信息头部 ---
          Row() {
            Circle()
              .width(70)
              .height(70)
              .fill('#D8D8D8')
              .margin({ right: 15 })

            Column({ space: 8 }) {
              Text("康刘勇")
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#3D59AB')
              Text("2022与你相约在粤嵌，爱你呦么么哒")
                .fontSize(13)
                .fontColor('#666666')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 20, bottom: 30, left: 10, right: 10 })
          .onClick(() => {
            router.pushUrl({ url: "pages/LoginPage" })
          })

          // --- B. 功能列表 ---
          Column() {
            ForEach(this.menuList, (item: string, index: number) => {
              this.SettingCell(item, index !== this.menuList.length - 1)
            })
          }
        }
        .width('90%')
        // 【修改点2】设置半透明背景
        // rgba(红, 绿, 蓝, 透明度0-1)
        // 0.85 表示 85% 不透明，你可以根据喜好调节这个数字(0.1 ~ 0.9)
        .backgroundColor('rgba(255, 255, 255, 0.85)')

        // 【可选特效】添加背景模糊（毛玻璃效果），让半透明看起来更高级
        // .backdropBlur(20)

        .borderRadius(12)
        .shadow({ radius: 10, color: '#1A000000', offsetY: 5 })
        .padding({ left: 15, right: 15, bottom: 10 })
        .margin({ top: 180 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
