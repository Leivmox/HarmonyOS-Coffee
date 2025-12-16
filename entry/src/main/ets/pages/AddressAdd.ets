 import { router } from '@kit.ArkUI'


@Entry

@Component

struct AddressAdd {

  // 通用输入行样式封装

  @Builder

  InputRow(title: string, placeholder: string, text: string, onChange: (val: string) => void) {

    Row() {

      Text(title)

        .width(80)

        .fontSize(16)

        .fontColor('#333')


      TextInput({ placeholder: placeholder, text: text })

        .layoutWeight(1)

        .backgroundColor(Color.Transparent)

        .fontSize(16)

        .placeholderColor('#ccc')

        .onChange((value: string) => {

          onChange(value)

        })

    }

    .height(55)

    .width('100%')

    .alignItems(VerticalAlign.Center)

  }


  build() {

    Column() {

      // 1. 顶部导航

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

        .padding({ left: 15 })


        Text("新增地址")

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


    }

    .width('100%')

    .height('100%')

    .backgroundColor('#F5F5F5')

  }

}